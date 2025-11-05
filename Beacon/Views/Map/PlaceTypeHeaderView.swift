//
//  PlaceTypeHeaderView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import SwiftUI

struct PlaceTypeHeaderView: View {
    @Binding var selectedType: PlaceType
    
    var body: some View {
        HStack{
            emojiView(for: selectedType)
                .id(selectedType)

            Text(selectedType.rawValue)
                .font(.title).bold()
                .foregroundStyle(.beaconOrange)
        }
        .padding(.horizontal)
        .padding(.vertical, 3)
        .glassEffect()
    }
}

@ViewBuilder
private func emojiView(for type: PlaceType) -> some View {
    switch type {
    case .cafe:
        CafeEmojiView()
    case .hotels:
        HotelEmojiView()
    case .restaurants:
        RestaurantEmojiView()
    }
}

#Preview {
    PlaceTypeHeaderView(selectedType: .constant(.restaurants))
}
