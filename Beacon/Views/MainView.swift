//
//  ContentView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View{
        TabView
        {
          NavigationStack
          {
            MapView()
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
        }
    }
}

#Preview {
    ContentView()
}
