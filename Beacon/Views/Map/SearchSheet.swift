//
//  SearchSheet.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 07/11/2025.
//

import SwiftUI
import SwiftData
import CoreLocation

struct SearchSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var vm: PlacesViewModel
    @ObservedObject var rs: RatingStore
    @Binding var selectedType: PlaceType
    @Binding var selectedPlace: Place?
    
    @State private var keyword: String = ""
    @State private var sliderRadius: Double
    @AppStorage("searchRadius") private var storedSearchRadius: Double = 1000
    @AppStorage("searchKeyword") private var storedKeyword: String = ""
    
    @State private var debounceTask: Task<Void, Never>?
    
    @StateObject private var autocomplete = AutocompleteModel()
    
    // How many characters in searchfield before fetch fires
    private let queryThreshold:Int = 3
    
    // Favorites filter
    @State private var showFavoritesOnly: Bool = false
    @Query private var favorites: [FavoritePlace]
    
    // Sorting
    enum SortMode: String, CaseIterable, Identifiable {
        case distance = "Distance"
        case rating = "Rating"
        case name = "A–Z"
        
        var id: String { rawValue }
    }
    // default sortMode
    @State private var sortMode: SortMode = .distance
    
    // Ratings for sorting by rating
    @Query private var allRatings: [Rating]
    
    private let defaultType: PlaceType = .cafe
    
    init(vm: PlacesViewModel, rs: RatingStore, selectedType: Binding<PlaceType>, selectedPlace: Binding<Place?>) {
        self._vm = ObservedObject(initialValue: vm)
        self._rs = ObservedObject(initialValue: rs)
        self._selectedType = selectedType
        self._selectedPlace = selectedPlace
        self._sliderRadius = State(initialValue: Double(vm.radius))
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Header
            HStack {
                // Instead of pull to refresh since its a sheet.
                Button("Refresh"){
                    Task { await performAutocompleteFetch() }
                }
                .buttonStyle(.glass)
                Spacer()
                Button {
                    clearFilters()
                } label: {
                    Label("Clear", systemImage: "arrow.counterclockwise")
                        .labelStyle(.titleAndIcon)
                }
                .buttonStyle(.bordered)
            }
            
            // Keyword (drives autocomplete)
            VStack(alignment: .leading, spacing: 6) {
                Text("Keyword")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                TextField("Search by name", text: $keyword)
                    .textFieldStyle(.roundedBorder)
            }
            
            // Segment Picker (kept for UX consistency; not used by autocomplete endpoint)
            VStack(alignment: .leading, spacing: 6) {
                Text("Category")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack{
                    CategoryEmoji(type: selectedType)
                    SegmentPicker(selection: $selectedType)
                }
            }
            
            // Radius slider (used by autocomplete fetch)
            VStack(alignment: .leading, spacing: 6) {
                Text("Radius (\(Int(sliderRadius)) m)")
                    .font(.caption)
                
                Slider(value: $sliderRadius, in: 100...5000) {
                    Text("Radius")
                }
                
                HStack {
                    Text("100")
                        .font(.caption2)
                    Spacer()
                    Text("5000")
                        .font(.caption2)
                }
            }
            
            // Sorting + Favorites filter
            VStack(alignment: .leading, spacing: 8) {
                Text("Sort by")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack{
                    Picker("Sort", selection: $sortMode) {
                        Text(SortMode.distance.rawValue).tag(SortMode.distance)
                        Text(SortMode.rating.rawValue).tag(SortMode.rating)
                        Text(SortMode.name.rawValue).tag(SortMode.name)
                    }
                    .pickerStyle(.segmented)
                    Spacer()
                    Picker("", selection: $showFavoritesOnly){
                        Text("Any").tag(false)
                        Text("♥").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                }
                
            }
            
            // MARK: - List Results
            
            // Results from autocomplete, mapped to Place
            Group {
                if let msg = autocomplete.message, !msg.isEmpty {
                    Text(msg)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(nil)
                }
                
                List(filteredAndSortedPlaces) { place in
                    Button {
                        selectedPlace = place
                        dismiss()
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(place.name)
                                    .font(.headline)
                                Spacer()
                                Text("\(place.distance) m")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            if let addr = place.address, !addr.isEmpty {
                                Text(addr)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            AverageRating(placeId: place.id)
                        }
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
            .padding(.top, 4)
        }
        .padding()
        .onAppear {
            keyword = storedKeyword
            // Align VM with current UI; autocomplete uses center + radius
            vm.categories = selectedType.geoapifyCategories
            vm.radius = Int(sliderRadius)
            // If we have a keyword meeting threshold, fetch immediately
            if keyword.trimmingCharacters(in: .whitespacesAndNewlines).count >= queryThreshold {
                Task { await performAutocompleteFetch() }
            }
        }
        .onDisappear {
            storedKeyword = keyword
        }
        .onChange(of: selectedType) { _, newValue in
            // Keep VM in sync; autocomplete endpoint does not use categories directly
            vm.categories = newValue.geoapifyCategories
            triggerDebouncedAutocomplete()
        }
        .onChange(of: sliderRadius) { _, newValue in
            vm.radius = Int(newValue)
            storedSearchRadius = newValue
            triggerDebouncedAutocomplete()
        }
        .onChange(of: keyword) { _, _ in
            triggerDebouncedAutocomplete()
        }
        .onChange(of: showFavoritesOnly) { _, _ in
            triggerDebouncedAutocomplete()
        }
    }
    
    
    // MARK: - FUNCTIONS
    
    // Map autocomplete results to our Place model so the rest of the app can use it
    private var mappedResults: [Place] {
        let center = vm.center
        return autocomplete.places.map { res in
            let lat = res.lat ?? 0
            let lon = res.lon ?? 0
            let distance = distanceMeters(from: center, to: CLLocationCoordinate2D(latitude: lat, longitude: lon))
            // Map the single category string into our Place.categories array
            let cats: [String]? = res.category.flatMap { [$0] }
            return Place(
                id: res.place_id ?? res.id,
                name: res.name,
                lat: lat,
                lon: lon,
                address: res.street,
                website: nil,
                distance: distance,
                opening_hours: nil,
                phone: nil,
                email: nil,
                categories: cats
            )
        }
    }
    
    // group our ratings with results by id
    private var ratingsAverageById: [String: Double] {
        let grouped = Dictionary(grouping: allRatings, by: { $0.id })
        var result: [String: Double] = [:]
        for (id, arr) in grouped {
            let avg = arr.map(\.value).reduce(0, +) / Double(arr.count)
            result[id] = avg
        }
        return result
    }
    
    private var favoriteIds: Set<String> {
        Set(favorites.map(\.id))
    }
    
    private var filteredAndSortedPlaces: [Place] {
        // First, filter by selected category using autocomplete category strings
        let categoryFiltered = mappedResults.filter { matchesSelectedType(categories: $0.categories) }
        
        // Optionally filter by favorites only
        let favoritesFiltered: [Place]
        if showFavoritesOnly {
            favoritesFiltered = categoryFiltered.filter { favoriteIds.contains($0.id) }
        } else {
            favoritesFiltered = categoryFiltered
        }
        
        // Then apply keyword filter
        let keywordFiltered: [Place]
        if keyword.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            keywordFiltered = favoritesFiltered
        } else {
            let key = keyword.lowercased()
            keywordFiltered = favoritesFiltered.filter { $0.name.lowercased().contains(key) }
        }
        
        // Finally, sort according to user preference
        switch sortMode {
        case .distance:
            return keywordFiltered.sorted { $0.distance < $1.distance }
        case .name:
            return keywordFiltered.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        case .rating:
            let avg = ratingsAverageById
            return keywordFiltered.sorted {
                let a = avg[$0.id] ?? 0
                let b = avg[$1.id] ?? 0
                if a == b {
                    if $0.distance == $1.distance {
                        return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                    }
                    return $0.distance < $1.distance
                }
                return a > b
            }
        }
    }
    
    // Category matching rules for autocomplete categories
    private func matchesSelectedType(categories: [String]?) -> Bool {
        // If categories are missing or empty, allow the item to pass through.
        // Change to `false` for stricter filter
        guard let cats = categories, !cats.isEmpty else { return true }
        switch selectedType {
            case .restaurants:
                // Any "catering.*" is accepted (restaurant, fast_food, cafe, etc.).
                return cats.contains(where: { $0.hasPrefix("catering.") })
            case .hotels:
                // Match hotel-related accommodation
                return cats.contains(where: { $0.hasPrefix("accommodation.hotel") })
            case .cafe:
                // Exact "catering.cafe"
                return cats.contains("catering.cafe")
        }
    }
    
    private func triggerDebouncedAutocomplete() {
        debounceTask?.cancel()
        debounceTask = Task { [keyword] in
            // Optional: avoid spamming API for very short queries
            guard keyword.trimmingCharacters(in: .whitespacesAndNewlines).count >= queryThreshold else {
                await MainActor.run { autocomplete.places = [] }
                return
            }
            // 300ms debounce
            try? await Task.sleep(nanoseconds: 300_000_000)
            await performAutocompleteFetch()
        }
    }
    
    // Sets filter to our current center so we only get hits from our location
    private func performAutocompleteFetch() async {
        await autocomplete.fetchSearches(
            text: keyword,
            lon: vm.center.longitude,
            lat: vm.center.latitude,
            radius: vm.radius,
            limit: vm.limit
        )
    }
    
    private func clearFilters() {
        selectedType = defaultType
        sliderRadius = 1000
        keyword = ""
        showFavoritesOnly = false
        storedKeyword = ""
        
        vm.categories = selectedType.geoapifyCategories
        vm.radius = 1000
        
        // Clear results
        autocomplete.places = []
    }
    
    // Need to calc distance since its not included in autocomplete fetch
    private func distanceMeters(from a: CLLocationCoordinate2D, to b: CLLocationCoordinate2D) -> Int {
        let locA = CLLocation(latitude: a.latitude, longitude: a.longitude)
        let locB = CLLocation(latitude: b.latitude, longitude: b.longitude)
        return Int(locA.distance(from: locB).rounded())
    }
}
