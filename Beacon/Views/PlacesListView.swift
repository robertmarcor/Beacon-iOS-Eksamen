//
//  PlacesListView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 04/11/2025.
//

import SwiftUI
import MapKit

struct PlacesListView: View {
    @ObservedObject var vm: PlacesViewModel
    @Binding var isSheetPresented: Bool
    @Binding var selectedType: PlaceType
    
    @State var mockPlaces: [Place]

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
                            Text("\(displayedPlaces[0].categories![0]) places")
                                .font(.title)
                                .foregroundStyle(.beaconOrange)
                            ForEach(displayedPlaces) { p in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(p.name)
                                            .font(.headline)
                                            .foregroundStyle(.beaconOrange)
                                        
                                    }
                                    
                                    if let hours = p.opening_hours, !hours.isEmpty {
                                        OpeningHoursBadge(place: p)
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
                                    
                                    Text("Distance: \(p.distance)m")
                                        .font(.subheadline)
                                    
                                    if let addr = p.address {
                                        Text(addr)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Text(String(format: "%.5f, %.5f", p.lat, p.lon))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
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
    }
}

#Preview {
    PlacesListView(
        vm: PlacesViewModel(),
        isSheetPresented: .constant(false),
        selectedType: .constant(PlaceType.restaurants),
        mockPlaces: mockPlaces
    )
}

