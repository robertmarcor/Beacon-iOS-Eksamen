//
//  PlacesListView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 04/11/2025.
//

import SwiftUI
import MapKit
import SwiftData

struct PlacesListView: View {
    @ObservedObject var vm: PlacesViewModel
    @Binding var isSheetPresented: Bool
    @Binding var selectedType: PlaceType
    @Binding var selectedPlace: Place?
    
    @State var mockPlaces: [Place]
    
    @Environment(\.modelContext) private var modelContext
    
    //MARK: Remove in the future, just dummy data for styling
    private var displayedPlaces: [Place] {
        vm.places.isEmpty ? mockPlaces : vm.places
    }
    
    var body: some View {
        NavigationView {
            Group {
                if vm.isLoading {
                    ProgressView()
                } else if let err = vm.errorMessage {
                    Text("Error: \(err)")
                        .foregroundStyle(.red)
                } else if displayedPlaces.isEmpty {
                    Text("No results")
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(displayedPlaces) { place in
                                Button {
                                    selectedPlace = place
                                    isSheetPresented = false
                                } label: {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(place.name)
                                                .font(.headline)
                                                .foregroundStyle(.beaconOrange)
                                            Spacer()
                                            LikeButton(place: place)
                                        }
                                        
                                        if let hours = place.opening_hours, !hours.isEmpty {
                                            OpeningHoursBadge(place: place)
                                            Text("Opening Hours")
                                                .font(.footnote.bold())
                                                .foregroundStyle(.secondary)
                                            
                                            Text(
                                                hours
                                                    .replacingOccurrences(of: ";", with: "\n")
                                                    .components(separatedBy: .newlines)
                                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                                                    .joined(separator: "\n")
                                            )
                                            .font(.subheadline)
                                        }
                                        
                                        Text("Distance: \(place.distance)m")
                                            .font(.subheadline)
                                        
                                        if let addr = place.address {
                                            Text(addr)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                        
                                        Text(String(format: "%.5f, %.5f", place.lat, place.lon))
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                .buttonStyle(.plain)
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                    }
                    .toolbar {
                        SegmentPicker(selection: $selectedType)
                        FetchButton(vm: vm)
                    }
                }
            }
        }
        .onAppear {
            vm.setModelContext(modelContext)
        }
    }
}

#Preview {
    PlacesListView(
        vm: PlacesViewModel(),
        isSheetPresented: .constant(false),
        selectedType: .constant(PlaceType.restaurants),
        selectedPlace: .constant(nil),
        mockPlaces: mockPlaces
    )
}

