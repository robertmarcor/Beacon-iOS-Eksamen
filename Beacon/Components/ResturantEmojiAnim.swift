
//
//  SwiftUIView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import SwiftUI

struct RestaurantEmojiView: View {
    @State private var deg = 0.0

    var body: some View {
        Text("🍽️")
            .font(.title)
            .rotationEffect(.degrees(deg))
            .onAppear {
                deg = 0
                withAnimation(.easeInOut(duration: 1)) {
                    deg = 360
                }
            }
    }
}


#Preview {
    RestaurantEmojiView()
}
