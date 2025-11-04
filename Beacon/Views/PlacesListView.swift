//
//  PlacesListView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 04/11/2025.
//

import SwiftUI
import MapKit

struct PlacesListView: View {
    @StateObject private var vm = PlacesViewModel()

    var body: some View {
        NavigationView {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if let err = vm.errorMessage {
                    Text("Error: \(err)").foregroundStyle(.red)
                } else if vm.places.isEmpty {
                    Text("No results")
                } else {
                    List(vm.places) { p in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(p.name).font(.headline)
                            if let addr = p.address { Text(addr).font(.caption).foregroundStyle(.secondary) }
                            Text(String(format: "%.5f, %.5f", p.lat, p.lon))
                                .font(.caption2).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("Places")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Oslo") {
                        vm.setCenter(.init(latitude: 59.9139, longitude: 10.7522))
                        Task { await vm.load() }
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reload") { Task { await vm.load() } }
                }
            }
        }
        .task { await vm.load() } // first load
    }
}


#Preview {
    PlacesListView()
}
