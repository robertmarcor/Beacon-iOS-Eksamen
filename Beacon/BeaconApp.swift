//
//  BeaconApp.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import SwiftUI
import SwiftData

@main
struct BeaconApp: App {
    private let container: ModelContainer
    private let ratingStore: RatingStore
    @StateObject private var placesVM = PlacesViewModel()
    
    init() {
        // One shared container for the entire app
        // Extend to include FavoritePlace as well
        self.container = try! ModelContainer(for: Rating.self, FavoritePlace.self)
        self.ratingStore = RatingStore(context: ModelContext(container))
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(ratingStore)
                .environmentObject(placesVM)
                .modelContainer(container)
        }
    }
}
