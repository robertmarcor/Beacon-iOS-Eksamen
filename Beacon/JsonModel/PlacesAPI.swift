//
//  GeoapifyPlaces.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import Foundation

// Setter opp response modellen for å ta imot JSON fra geoapify
// Fetch and mapping data to our model
enum Geoapify{
    // Grab our API key from Project
    static var apiKey: String { Secrets.geoapifyAPIKey}
    
    // Building our URL with parameters as required by geoapify
    static func fetchPlaces(
        lon: Double,
        lat: Double,
        radius: Int = 1000,
        category: [String] = ["accommodation.hotel"],
        limit: Int = 10) async throws -> [Place]{
            // Bygge url
            var urlComps = URLComponents(string: "https://api.geoapify.com/v2/places")!
            urlComps.queryItems = [
                .init(name: "apiKey", value: apiKey),
                .init(name: "categories", value: category.joined(separator: ",")),
                .init(name: "filter", value: "circle:\(lon),\(lat),\(radius)"),
                .init(name: "bias", value: "proximity:\(lon),\(lat)"),
                .init(name: "limit", value: String(limit))
            ]
            guard let url = urlComps.url else { throw URLError(.badURL) }
            print("Geoapify request URL: \(url.absoluteString)")

            // Swift fetch, throw error if bad url
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            // decode and map the response to our place struct
            let dto = try JSONDecoder().decode(PlacesResponse.self, from: data)
            return dto.features.map { feature in
                let coords = feature.geometry.coordinates
                return Place(
                    id: feature.properties.place_id,
                    name: feature.properties.name ?? "Unnamed",
                    lat: coords.count > 1 ? coords[1] : 0,
                    lon: coords.first ?? 0,
                    address: feature.properties.formatted,
                    website: feature.properties.website,
                    distance: feature.properties.distance,
                    opening_hours: feature.properties.opening_hours ?? "",
                    phone: feature.properties.contact?.phone,
                    email: feature.properties.contact?.email,
                    categories: feature.properties.categories,
                )
            }

        }
    
}
// AI Generert kode for å sjekke opening hours
// MARK: - Opening hours parsing and status (device time zone, 60 min closesSoon)
extension Place {
    struct OpeningStatus {
        let isOpen: Bool
        let closesSoon: Bool
        let closesAt: Date?
    }
    
    // Public entry point
    func openingStatus(at date: Date = Date(), timeZone: TimeZone = .current, closesSoonThresholdMinutes: Int = 60) -> OpeningStatus? {
        guard let hours = opening_hours, !hours.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }
        let schedule = OpeningHoursParser.parse(hoursString: hours)
        return OpeningHoursParser.status(for: schedule, at: date, timeZone: timeZone, closesSoonThresholdMinutes: closesSoonThresholdMinutes)
    }
}

// MARK: - Internal parser
private enum OpeningHoursParser {
    // 1 = Sunday in Apple Calendar, map Mo..Su to 2..1
    enum Day: Int, CaseIterable {
        case su = 1, mo = 2, tu = 3, we = 4, th = 5, fr = 6, sa = 7
        
        static func from(token: String) -> Day? {
            switch token.lowercased() {
            case "mo": return .mo
            case "tu": return .tu
            case "we": return .we
            case "th": return .th
            case "fr": return .fr
            case "sa": return .sa
            case "su": return .su
            default: return nil
            }
        }
    }
    
    struct Interval {
        // minutes since midnight [start, end); if overnight, we split into two intervals across days
        let startMinutes: Int
        let endMinutes: Int
    }
    
    // Schedule: per day intervals
    typealias Schedule = [Day: [Interval]]
    
    static func parse(hoursString: String) -> Schedule {
        var schedule: Schedule = [:]
        
        // Normalize separators:
        // Split first on ';'
        var chunks = hoursString.split(separator: ";").map { String($0).trimmingCharacters(in: .whitespaces) }
        
        // Some inputs use commas to separate rules too, e.g. "Su-Th 11:00-23:00, Fr,Sa 11:00-04:00"
        // We’ll further split chunks where a comma is followed by a day token.
        func splitOnCommaDay(_ s: String) -> [String] {
            // Look for occurrences of ", " followed by a day token (Mo|Tu|We|Th|Fr|Sa|Su)
            let pattern = #",\s+(Mo|Tu|We|Th|Fr|Sa|Su)\b"#
            guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [s] }
            var parts: [String] = []
            var lastIndex = s.startIndex
            let ns = s as NSString
            let matches = regex.matches(in: s, options: [], range: NSRange(location: 0, length: ns.length))
            if matches.isEmpty {
                return [s]
            }
            for m in matches {
                let r = Range(m.range, in: s)!
                let prefix = String(s[lastIndex..<r.lowerBound])
                parts.append(prefix.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: ",")))
                lastIndex = r.lowerBound
            }
            // Append the tail
            let tail = String(s[lastIndex...])
            parts.append(tail.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: ",")))
            // Clean empty
            return parts.filter { !$0.isEmpty }
        }
        
        chunks = chunks.flatMap { splitOnCommaDay($0) }
        
        // Each chunk like "Su-Th 11:00-23:00" or "Fr,Sa 11:00-04:00" or "Mo 09:00-21:00, 22:00-02:00"
        for chunk in chunks {
            // Split days part and times part by first whitespace
            guard let spaceIdx = chunk.firstIndex(where: { $0.isWhitespace }) else { continue }
            let daysPart = String(chunk[..<spaceIdx]).trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: ","))
            let timesPart = String(chunk[spaceIdx...]).trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Parse days: can be "Su-Th" or "Fr,Sa" or single "Mo"
            let days = expandDays(from: daysPart)
            guard !days.isEmpty else { continue }
            
            // timesPart can contain multiple intervals separated by commas
            let timeRanges = timesPart.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            for tr in timeRanges {
                // Expect "HH:mm-HH:mm"
                let comps = tr.split(separator: "-").map { String($0).trimmingCharacters(in: .whitespaces) }
                guard comps.count == 2,
                      let start = minutes(fromHHmm: comps[0]),
                      let end = minutes(fromHHmm: comps[1])
                else { continue }
                
                if start <= end {
                    // Same-day interval
                    for d in days {
                        schedule[d, default: []].append(Interval(startMinutes: start, endMinutes: end))
                    }
                } else {
                    // Overnight interval: split across day and next day
                    for d in days {
                        // Part 1: today start -> 24:00
                        schedule[d, default: []].append(Interval(startMinutes: start, endMinutes: 24*60))
                        // Part 2: next day 00:00 -> end
                        if let next = nextDay(after: d) {
                            schedule[next, default: []].append(Interval(startMinutes: 0, endMinutes: end))
                        }
                    }
                }
            }
        }
        
        // Sort and merge overlapping intervals per day for safety
        for d in Day.allCases {
            if var arr = schedule[d] {
                arr.sort { $0.startMinutes < $1.startMinutes }
                var merged: [Interval] = []
                for iv in arr {
                    if let last = merged.last, iv.startMinutes <= last.endMinutes {
                        // overlap/adjacent: merge
                        let newEnd = max(last.endMinutes, iv.endMinutes)
                        merged.removeLast()
                        merged.append(Interval(startMinutes: last.startMinutes, endMinutes: newEnd))
                    } else {
                        merged.append(iv)
                    }
                }
                schedule[d] = merged
            }
        }
        
        return schedule
    }
    
    static func status(for schedule: Schedule, at date: Date, timeZone: TimeZone, closesSoonThresholdMinutes: Int) -> Place.OpeningStatus {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        
        let comps = calendar.dateComponents([.weekday, .hour, .minute, .year, .month, .day], from: date)
        guard let weekday = comps.weekday, let hour = comps.hour, let minute = comps.minute else {
            return .init(isOpen: false, closesSoon: false, closesAt: nil)
        }
        let currentDay = Day(rawValue: weekday) ?? .mo
        let nowMinutes = hour * 60 + minute
        
        let todays = schedule[currentDay] ?? []
        
        // Determine if open and when it closes
        var isOpen = false
        var closesAtMinutes: Int?
        for iv in todays {
            if nowMinutes >= iv.startMinutes && nowMinutes < iv.endMinutes {
                isOpen = true
                closesAtMinutes = iv.endMinutes
                break
            }
        }
        
        if isOpen, let closeMin = closesAtMinutes {
            let remaining = closeMin - nowMinutes
            let closesSoon = remaining <= closesSoonThresholdMinutes
            // Build closesAt Date
            var closeComps = comps
            closeComps.hour = closeMin / 60
            closeComps.minute = closeMin % 60
            closeComps.second = 0
            let closesAt = calendar.date(from: closeComps)
            return .init(isOpen: true, closesSoon: closesSoon, closesAt: closesAt)
        } else {
            return .init(isOpen: false, closesSoon: false, closesAt: nil)
        }
    }
    
    private static func minutes(fromHHmm s: String) -> Int? {
        let parts = s.split(separator: ":")
        guard parts.count == 2,
              let h = Int(parts[0]),
              let m = Int(parts[1]),
              (0..<24).contains(h),
              (0..<60).contains(m) else { return nil }
        return h * 60 + m
    }
    
    private static func expandDays(from token: String) -> [Day] {
        // token could be "Su-Th", "Fr,Sa", "Mo"
        var days: [Day] = []
        let list = token.split(separator: ",").map { String($0) }
        for item in list {
            let trimmed = item.trimmingCharacters(in: .whitespaces)
            if trimmed.contains("-") {
                let ends = trimmed.split(separator: "-").map { String($0) }
                if ends.count == 2, let start = Day.from(token: ends[0]), let end = Day.from(token: ends[1]) {
                    days.append(contentsOf: rangeDays(from: start, to: end))
                }
            } else if let d = Day.from(token: trimmed) {
                days.append(d)
            }
        }
        // Deduplicate while preserving order
        var seen = Set<Int>()
        let unique = days.filter { seen.insert($0.rawValue).inserted }
        return unique
    }
    
    private static func rangeDays(from start: Day, to end: Day) -> [Day] {
        if start.rawValue <= end.rawValue {
            return (start.rawValue...end.rawValue).compactMap { Day(rawValue: $0) }
        } else {
            // wrap around week (e.g., Fr-Su)
            return (start.rawValue...7).compactMap { Day(rawValue: $0) } + (1...end.rawValue).compactMap { Day(rawValue: $0) }
        }
    }
    
    private static func nextDay(after d: Day) -> Day? {
        Day(rawValue: d.rawValue == 7 ? 1 : d.rawValue + 1)
    }
}

