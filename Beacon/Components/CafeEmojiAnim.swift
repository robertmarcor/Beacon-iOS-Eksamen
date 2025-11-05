//
//  SwiftUIView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import SwiftUI

struct CafeEmojiView: View {
    @State private var fade = 0.0
    @State private var y: CGFloat = 8
    @State private var play = false
    @State private var particleSize: CGFloat = 4

    var body: some View {
        Text("☕️")
            .font(.title)
            .background(
                ZStack {
                    ForEach(0..<3, id: \.self) { i in
                        Text("🌫️")
                            .font(.system(size: particleSize))
                            .clipShape(Circle())
                            .offset(x: CGFloat(i - 1) * 5,
                                    y: play ? -50 : 0)
                            .opacity(play ? 0 : 1)
                            .animation(
                                .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(i - 1) * 0.8),
                                value: play
                            )
                    }
                }
            )
            .onAppear {
                play = true
            }
    }
}

#Preview { CafeEmojiView() }
