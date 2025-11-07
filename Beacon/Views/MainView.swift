//
//  ContentView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @EnvironmentObject private var vm: PlacesViewModel
    @EnvironmentObject private var ratingStore: RatingStore
    @Environment(\.modelContext) private var modelContext
    
    var body: some View{
        TabView
        {
            NavigationStack
            {
                MapView(mockPlaces: mockPlaces)
            }
            .tabItem
            {
                Label("Utforsk", systemImage: "map")
            }
            
            NavigationStack
            {
                FavoritesView()
            }
            .tabItem
            {
                Label("Favoritter", systemImage: "heart")
            }
            NavigationStack
            {
                RatingHistory()
            }
            .tabItem
            {
                Label("Rating", systemImage: "star")
            }
        }
        .task {
            vm.setModelContext(modelContext)
        }
        .onChange(of: vm.fetchTime) { _, newValue in
            for place in vm.places {
                let value = Double.random(in: 1...5)
                ratingStore.addRating(id: place.id, name: place.name, value: value)
            }
        }
    }
}

#Preview {
    // Preview with the same environment as runtime so sheets won’t crash
    let container = try! ModelContainer(
        for: Rating.self, FavoritePlace.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let store = RatingStore(context: ModelContext(container))
    let places = PlacesViewModel()
    places.setModelContext(ModelContext(container))
    
    return MainView()
        .environmentObject(store)
        .environmentObject(places)
        .modelContainer(container)
}
