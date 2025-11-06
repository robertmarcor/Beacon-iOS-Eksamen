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

    init() {
        // One shared container for the entire app
        self.container = try! ModelContainer(for: Rating.self)
        self.ratingStore = RatingStore(context: ModelContext(container))
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ratingStore)
                .modelContainer(container)
        }
    }
}
