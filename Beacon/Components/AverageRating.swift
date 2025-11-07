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
    let showFiveStars: Bool
    let showEmptyText: Bool
    
    @Query private var ratings: [Rating]
    
    // Init the placeId so we can use it in our Query
    init(placeId: String,
         showFiveStars: Bool = false,
         showEmptyText: Bool = true)
    {
        self.placeId = placeId
        self.showFiveStars = showFiveStars
        self.showEmptyText = showEmptyText
        _ratings = Query(
            filter: #Predicate<Rating> { $0.id == placeId }
        )
    }
    
    // calculate the avg by sum/count
    private var average: Double {
        guard !ratings.isEmpty else { return 0 }
        return ratings.map(\.value).reduce(0, +) / Double(ratings.count)
    }
    
    // Check to display a full/half/empty star each loop based on the avg
    private func starSymbol(for position: Int, average: Double) -> String {
        if average >= Double(position) {
            return "star.fill"
        } else if average >= Double(position) - 0.5 {
            return "star.leadinghalf.filled"
        } else {
            return "star"
        }
    }
    
    
    var body: some View {
        if ratings.isEmpty {
            if showEmptyText{
                Text("No ratings yet")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        } else {
            if showFiveStars {
                HStack{
                    HStack{
                        ForEach(1...5, id: \.self) { i in
                            Image(systemName: starSymbol(for: i, average: average))
                                .foregroundStyle(.yellow)
                        }
                    }
                    Text(String(format: "%.1f", average))
                        .font(.subheadline.bold())
                    
                    Text("(\(ratings.count))")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
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
}
