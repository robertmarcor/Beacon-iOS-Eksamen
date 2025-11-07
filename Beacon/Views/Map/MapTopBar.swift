//
//  MapTopBar.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 04/11/2025.
//

import SwiftUI

struct MapTopBar: View {
    @ObservedObject var vm: PlacesViewModel
    @Binding var isSheetPresented: Bool
    @Binding var selectedType: PlaceType
    
    var body: some View {
        VStack{
            PlaceTypeHeaderView(selectedType: $selectedType)
            HStack{
                Button {
                    isSheetPresented = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "list.bullet")
                    }
                    .contentShape(Capsule())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 16)
                    .glassEffect()
                }
                SegmentPicker(selection: $selectedType)
                FetchButton(vm: vm)
                
            }
        }
        .padding(.horizontal)
        .padding(.top, 50)
    }
}

#Preview {
    MapTopBar(vm: PlacesViewModel(), isSheetPresented: .constant(false), selectedType: .constant(.restaurants))
}
