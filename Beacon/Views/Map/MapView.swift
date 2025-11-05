//
//  Utforsk.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @Namespace private var mapScope
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 60.3913, longitude: 5.3221),
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    @State private var selectedPlace: Place?
    @State var mockPlaces: [Place]
    
    //Sheets
    @State private var isListViewSheetOpen = false
    @State private var isSearchPresented = false
    
    @State private var selectedType: PlaceType = .restaurants

    @StateObject private var vm = PlacesViewModel()
    
    private let locationManager = CLLocationManager()

    // Persisted map center
    @AppStorage("mapCenterLat") private var storedLat: Double = 60.3913
    @AppStorage("mapCenterLon") private var storedLon: Double = 5.3221
    
    var body: some View {
            Map(position: $camera, scope: mapScope) {
                Annotation("",coordinate: CLLocationCoordinate2D(latitude: storedLat, longitude: storedLon)){
                    Image(systemName: "scope")
                        .foregroundStyle(.red)
                        
                }
                
                ForEach(vm.places.isEmpty ? mockPlaces : vm.places) { place in
                    Annotation("", coordinate: place.coordinate) {
                        VStack(spacing: 4) {
                            Image((selectedPlace?.id == place.id) ? "logo3" : "pin2")
                                .resizable()
                                .frame(width: 44, height: 44)
                            Text(place.name)
                                .font(.caption2)
                                .foregroundColor(.beaconOrange)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.black.opacity(0.7))
                                .cornerRadius(4)
                        }
                        .onTapGesture {
                            selectedPlace = place
                        }
                    }

                }
                
            }
            .tint(.beaconOrange)
            .mapStyle(.standard(pointsOfInterest: .excludingAll))
        
            .overlay(alignment: .top){
                MapTopBar(vm: vm, isSheetPresented: $isListViewSheetOpen, selectedType: $selectedType)
            }
            .overlay(alignment: .bottom){
                MapBottomBar(scope: mapScope, isSearchPresented: $isSearchPresented)
            }.mapScope(mapScope)
            .ignoresSafeArea()
        
            .mapControls {
            }
            .onMapCameraChange { context in
                let c = context.region.center
                storedLat = c.latitude
                storedLon = c.longitude
                vm.setCenter(c)
            }
            .onAppear {
                let restoredCenter = CLLocationCoordinate2D(latitude: storedLat, longitude: storedLon)
                camera = .region(
                    MKCoordinateRegion(
                        center: restoredCenter,
                        span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                )
                vm.center = restoredCenter
                vm.categories = selectedType.geoapifyCategories
                locationManager.requestWhenInUseAuthorization()
                
                //MARK: For Preview only to prevent refetches
            }
            .onChange(of: selectedType) { _, newValue in
                vm.categories = newValue.geoapifyCategories
            }
            .sheet(isPresented: $isListViewSheetOpen) {
                VStack(spacing: 16) {
                    PlacesListView(vm: vm, isSheetPresented: $isListViewSheetOpen, selectedType: $selectedType, mockPlaces: mockPlaces)
                        .presentationDetents([.medium, .large])
                        .tint(.beaconOrange)
                        
                }
                .padding()
            }
            .sheet(isPresented: $isSearchPresented) {
                VStack(spacing: 16) {
                    SearchSheet()
                        .presentationDetents([.medium])
                }
            }
            .sheet(item: $selectedPlace) { place in
                PlaceSheet(place: place)
                    .presentationDetents([.medium])
            }
    }
}

#Preview {
    MapView(mockPlaces: mockPlaces)
}

