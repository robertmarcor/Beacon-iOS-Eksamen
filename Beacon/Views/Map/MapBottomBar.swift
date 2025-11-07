//
//  MapBottomBar.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 04/11/2025.
//

import SwiftUI
import MapKit

struct MapBottomBar: View {
    var scope: Namespace.ID
    @Binding var isSearchPresented: Bool
    
    var body: some View {
        HStack{
            SearchButton(isSearchPresented: $isSearchPresented)
            Spacer()
            MapKit.MapUserLocationButton(scope: scope)
                .tint(.beaconOrange)
                .clipShape(Circle())
                .padding(6)
                .glassEffect()
        }
        .padding(.bottom, 80)
        .padding(.horizontal)
    }
}

