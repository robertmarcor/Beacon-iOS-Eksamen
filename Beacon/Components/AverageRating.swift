//
//  AverageRating.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 06/11/2025.
//

import SwiftUI
import SwiftData

struct AverageRating: View {
    let placeId: String
    
    @Query private var ratings: [Rating]
    
    init(placeId: String) {
        self.placeId = placeId
        _ratings = Query(
            filter: #Predicate<Rating> { $0.id == placeId }
        )
    }
    
    private var average: Double {
        guard !ratings.isEmpty else { return 0 }
        return ratings.map(\.value).reduce(0, +) / Double(ratings.count)
    }
    
    var body: some View {
        if ratings.isEmpty {
            Text("No ratings yet")
                .font(.caption)
                .foregroundStyle(.secondary)
        } else {
            HStack(spacing: 6) {
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
                Text(String(format: "%.1f", average))
                    .font(.subheadline.bold())
                Text("(\(ratings.count))")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
