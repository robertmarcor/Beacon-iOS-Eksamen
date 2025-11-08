//
//  PlaceTypeHeaderView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import SwiftUI

struct CategoryHeader: View {
    @Binding var selectedType: PlaceType
    
    var body: some View {
        HStack{
            CategoryEmoji(type: selectedType)
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

#Preview {
    CategoryHeader(selectedType: .constant(.restaurants))
}
