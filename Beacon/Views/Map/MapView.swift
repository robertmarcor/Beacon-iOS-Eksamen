//
//  Utforsk.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct MapView: View {
    @Namespace private var mapScope
    @State private var camera: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D.bergen,
            span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )
    @State private var selectedPlace: Place?
    @State var mockPlaces: [Place]
    
    //Sheets
    @State private var isListViewSheetOpen = false
    @State private var isSearchPresented = false
    
    @State private var selectedType: PlaceType = .restaurants
    
    @EnvironmentObject private var vm: PlacesViewModel
    @EnvironmentObject var ratingStore: RatingStore
    
    private let locationManager = CLLocationManager()
    
    // Persisted map center
    @AppStorage("mapCenterLat") private var storedLat: Double = 60.3913
    @AppStorage("mapCenterLon") private var storedLon: Double = 5.3221
    
    private var displayedPlaces: [Place] {
        vm.places.isEmpty ? mockPlaces : vm.places
    }
    
    var body: some View {
        Map(position: $camera, scope: mapScope) {
            ForEach(displayedPlaces) { place in
                let isSelected = (selectedPlace?.id == place.id)
                Annotation("", coordinate: place.coordinate) {
                    PlaceAnnotationView(
                        place: place,
                        isSelected: isSelected
                    ) {
                        select(place: place)
                    }
                }
            }
        }
        .tint(.beaconOrange)
        .mapStyle(.standard(pointsOfInterest: .excludingAll))
        .overlay(alignment: .center) {
            Image(systemName: "scope")
                .font(.system(size: 14, weight: .regular))
                .foregroundStyle(.red)
                .shadow(radius: 1)
                .allowsHitTesting(false)
        }
        .overlay(alignment: .top){
            MapTopBar(vm: vm, isSheetPresented: $isListViewSheetOpen, selectedType: $selectedType)
        }
        .overlay(alignment: .bottom){
            MapBottomBar(scope: mapScope, isSearchPresented: $isSearchPresented)
        }
        .mapScope(mapScope)
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
        }
        .onChange(of: selectedType) { _, newValue in
            vm.categories = newValue.geoapifyCategories
        }
        .onChange(of: vm.fetchTime){
            if let region = vm.region{
                camera = .region(region)
            }
        }
        .sheet(isPresented: $isListViewSheetOpen) {
            VStack(spacing: 16) {
                PlacesListView(
                    vm: vm,
                    isSheetPresented: $isListViewSheetOpen,
                    selectedType: $selectedType,
                    selectedPlace: $selectedPlace,
                    mockPlaces: mockPlaces
                )
                .presentationDetents([.medium, .large])
                .tint(.beaconOrange)
            }
            .padding()
        }
        .sheet(isPresented: $isSearchPresented) {
            VStack(spacing: 16) {
                // Pass RatingStore as required by SearchSheet.init(vm:rs:selectedType:selectedPlace:)
                SearchSheet(vm: vm, rs: ratingStore, selectedType: $selectedType, selectedPlace: $selectedPlace)
                    .presentationDetents([.medium, .large])
            }
        }
        .sheet(item: $selectedPlace) { place in
            PlaceDetailedView(place: place)
                .presentationDetents([.medium])
        }
    }
    
    private func select(place: Place) {
        selectedPlace = place
        let region = MKCoordinateRegion(
            center: place.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.0005, longitudeDelta: 0.0005)
        )
        withAnimation(.easeInOut(duration: 1.5)) {
            camera = .region(region)
        }
    }
}

private struct PlaceAnnotationView: View {
    let place: Place
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        VStack{
            Image(isSelected ? "logo3" : "pin2")
                .resizable()
                .frame(width: 66, height: 66)
            Text(place.name)
                .font(.caption2)
                .foregroundColor(.beaconOrange)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .cornerRadius(4)
                .glassEffect()
                .offset(y: -25)
            AverageRating(placeId: place.id, showEmptyText: false)
                .offset(y: -30)
        }
        .onTapGesture { onTap() }
    }
}

#Preview {
    // Provide the same environment as the app: shared VM + container
    let container = try! ModelContainer(
        for: Rating.self, FavoritePlace.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let places = PlacesViewModel()
    places.setModelContext(ModelContext(container))
    
    return MapView(mockPlaces: mockPlaces)
        .environmentObject(places)
        .modelContainer(container)
}
