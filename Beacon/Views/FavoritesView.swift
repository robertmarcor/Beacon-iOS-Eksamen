//
//  MineStederView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var vm: PlacesViewModel
    
    @Query private var favorites: [FavoritePlace]
    
    var body: some View {
        Group {
            if favorites.isEmpty {
                ContentUnavailableView(
                    "No favorites yet",
                    systemImage: "heart",
                    description: Text("Tap the heart on a place to save it here.")
                )
            } else {
                List {
                    ForEach(favorites) { fav in
                        NavigationLink(destination: PlaceDetailedView(place: convert(fav))) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(fav.name)
                                    .font(.headline)
                                if let addr = fav.address, !addr.isEmpty {
                                    Text(addr)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                }
                            }
                        }
                    }
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("Favorites")
        .onAppear(){
            if favorites.isEmpty{
                vm.toggleFavorite(mockPlaces[0])
            }
        }
    }
    
    // Helper to convert into place so we can use it with our DetailedView
    private func convert(_ fav: FavoritePlace) -> Place {
        Place(
            id: fav.id,
            name: fav.name,
            lat: fav.lat,
            lon: fav.lon,
            address: fav.address,
            website: fav.website,
            distance: fav.distance,
            opening_hours: fav.opening_hours,
            phone: fav.phone,
            email: fav.email,
            categories: fav.categories
        )
    }
}

#Preview {
    FavoritesView()
}
