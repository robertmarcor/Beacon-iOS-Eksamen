//
//  LikeButton.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 06/11/2025.
//

import SwiftUI

struct LikeButton: View {
    let place: Place
    @EnvironmentObject var vm: PlacesViewModel
    
    var body: some View {
        Button {
            vm.toggleFavorite(place)
        } label: {
            Image(systemName: vm.isFavorite(place) ? "heart.fill" : "heart")
                .foregroundStyle(vm.isFavorite(place) ? .red : .secondary)
                .accessibilityLabel(vm.isFavorite(place) ? Text("Remove Favorite") : Text("Add to Favorites"))
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
    }
}

#Preview {
    // Provide a simple unmanaged instance for preview
    let p = Place(id: "demo", name: "Demo Place", lat: 0, lon: 0, address: nil, website: nil, distance: 0, opening_hours: nil, phone: nil, email: nil, categories: nil)
    let vm = PlacesViewModel()
    return LikeButton(place: p)
        .environmentObject(vm)
}
