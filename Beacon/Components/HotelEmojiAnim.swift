//
//  SwiftUIView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import SwiftUI

struct HotelEmojiView: View {
    @State private var scale: CGFloat = 0.5

    var body: some View {
        Text("🏨")
            .font(.title)
            .scaleEffect(scale)
            .onAppear {
                scale = 0.5
                withAnimation(.spring(response: 1, dampingFraction: 0.5)) {
                    scale = 1
                }
            }
    }
}



#Preview {
    HotelEmojiView()
}
