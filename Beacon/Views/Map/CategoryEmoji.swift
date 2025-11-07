// CategoryEmoji.swift
import SwiftUI

struct CategoryEmoji: View {
    let type: PlaceType
    
    var body: some View {
        switch type {
        case .cafe:
            Emoji.Cafe()
        case .hotels:
            Emoji.Hotel()
        case .restaurants:
            Emoji.Restaurant()
        }
    }
}

private extension CategoryEmoji {
    enum Emoji {
        struct Cafe: View {
            @State private var play = false
            @State private var particleSize: CGFloat = 4
            
            var body: some View {
                Text("☕️")
                    .font(.title)
                    .background(
                        ZStack {
                            // Creates 3 particles, each with its own delay and offset
                            // offset is just iteration * a number, same goes for delay
                            // plays for 2 seconds then fades into 0 opacity
                            ForEach(0..<3, id: \.self) { i in
                                Text("🌫️")
                                    .font(.system(size: particleSize))
                                    .clipShape(Circle())
                                    .offset(
                                        x: CGFloat(i - 1) * 5,
                                        y: play ? -50 : 0
                                    )
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
                    .onAppear { play = true }
            }
        }
        
        struct Hotel: View {
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
        
        struct Restaurant: View {
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
    }
}
