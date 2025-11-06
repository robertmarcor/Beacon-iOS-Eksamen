//
//  ContentView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
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
            MineStederView()
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
        .tint(.highlightOrange)
    }
}

#Preview {
    // Preview with the same environment as runtime so sheets won’t crash
    let container = try! ModelContainer(
        for: Rating.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let store = RatingStore(context: ModelContext(container))

    return ContentView()
        .environmentObject(store)
        .modelContainer(container)
}
