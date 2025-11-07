//
//  RatingHistory.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 06/11/2025.
//

import SwiftUI
import SwiftData

struct RatingHistory: View {
    @EnvironmentObject private var ratingStore: RatingStore
    @Query(sort: \Rating.id) private var data: [Rating]
    
    var body: some View {
        List {
            if data.isEmpty {
                Text("No ratings yet")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(data, id: \.persistentModelID) { rating in
                    HStack {
                        Text(rating.name)
                        Spacer()
                        Text(String(format: "%.1f ★", rating.value))
                            .monospacedDigit()
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Mine Steder")
        .onAppear{
            if data.isEmpty{
                ratingStore.addRating(id: "1", name: "Test", value: 3.0)
                ratingStore.addRating(id: "1", name: "Test1", value: 3.0)
                ratingStore.addRating(id: "2", name: "Test2", value: 3.0)
            }
        }
    }
}

#Preview {
    RatingHistory().modelContainer(for: [Rating.self], inMemory: true)
}
