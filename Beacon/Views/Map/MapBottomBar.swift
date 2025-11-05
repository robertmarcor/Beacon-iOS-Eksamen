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
            Button {
                isSearchPresented = true
            } label: {
                Image(systemName: "magnifyingglass")
            }
            .clipShape(Circle())
            .padding(18)
            .glassEffect()
            .padding(.bottom, 8)
            Spacer()
            MapKit.MapUserLocationButton(scope: scope)
                .tint(.beaconOrange)
                .clipShape(Circle())
                .padding(6)
                .glassEffect()
        }
        .padding(.bottom, 50)
        .padding(.horizontal)
    }
}

