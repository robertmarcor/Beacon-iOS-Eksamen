//
//  OpeningHoursBadge.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import SwiftUI

struct OpeningHoursBadge: View {
    let place: Place
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                if let status = place.openingStatus(at: Date(), timeZone: TimeZone.current, closesSoonThresholdMinutes: 60) {
                    if status.isOpen {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(status.closesSoon ? Color.yellow : Color.green)
                                .frame(width: 8, height: 8)
                            if let close = status.closesAt {
                                Text("Open • closes \(timeString(from: close))")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("Open")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.12))
                        .clipShape(Capsule())
                    } else {
                        HStack(spacing: 6) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 8, height: 8)
                            Text("Closed")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.red.opacity(0.12))
                        .clipShape(Capsule())
                    }
                }
            }
        }
    }
    
    // AI Generated
    private func timeString(from date: Date) -> String {
        let fmt = DateFormatter()
        fmt.timeStyle = .short
        fmt.dateStyle = .none
        fmt.locale = Locale.current
        fmt.timeZone = TimeZone.current
        return fmt.string(from: date)
    }
}

#Preview {
    OpeningHoursBadge(place: mockPlaces[1])
}
