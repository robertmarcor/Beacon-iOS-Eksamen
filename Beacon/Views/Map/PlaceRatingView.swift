//
//  PlaceRatingSheet.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import SwiftUI
import SwiftData

struct PlaceRatingView: View {
    let placeId: String
    let placeName: String
    
    @EnvironmentObject var ratingStore: RatingStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRating: Double = 0.0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Rate \(placeName)")
                .font(.headline)
            
            HStack(spacing: 12) {
                // Loop giving each star its own number, 1-5. Tap 3rd star = 3.0
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= Int(selectedRating) ? "star.fill" : "star")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 34, height: 34)
                        .foregroundStyle(star <= Int(selectedRating) ? .yellow : .secondary)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedRating = Double(star)
                        }
                }
            }
            .padding(.vertical, 8)
            
            HStack {
                Button("Cancel") {
                    selectedRating = 0
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                // Call our RatingStore
                Button("Submit") {
                    ratingStore.addRating(id: placeId, name: placeName ,value: selectedRating )
                    selectedRating = 0
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .tint(.beaconOrange)
                .disabled(selectedRating == 0)
            }
        }
        .padding()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Rating.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let store = RatingStore(context: ModelContext(container))
    
    return PlaceRatingView(placeId: "a1", placeName: "Sample Place")
        .environmentObject(store)
        .modelContainer(container)
}
