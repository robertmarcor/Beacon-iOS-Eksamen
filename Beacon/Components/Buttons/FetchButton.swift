//
//  FetchButton.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 04/11/2025.
//

import SwiftUI

struct FetchButton: View {
    @ObservedObject var vm: PlacesViewModel
    @State private var rotate = false
    
    var body: some View {
        Button {
            Task {
                await vm.load()
            }
            withAnimation(.linear(duration: 0.6)) {
                rotate = true
            }
        } label: {
            Image(systemName: "arrow.triangle.2.circlepath")
                .rotationEffect(.degrees(rotate ? 360 : 0))
        }
        .padding(12)
        .contentShape(Rectangle()) // Easier tap
        .glassEffect()
    }
}
