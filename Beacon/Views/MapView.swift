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
    @Namespace private var locationBtn
    private let locationManager = CLLocationManager()
    @State private var isSheetPresented = false

    // Persisted map center and zoom (span)
    @AppStorage("mapCenterLat") private var storedLat: Double = 60.3913
    @AppStorage("mapCenterLon") private var storedLon: Double = 5.3221
    @AppStorage("mapSpanLat") private var storedSpanLat: Double = 0.05
    @AppStorage("mapSpanLon") private var storedSpanLon: Double = 0.05

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 60.3913, longitude: 5.3221),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    )

    var body: some View {
        ZStack {
            Map(position: $position, scope: locationBtn) {
            }
            .ignoresSafeArea()
            .mapControls {
                // Add other Map controls here if needed
            }

            VStack {
                HStack{
                    Button {
                        isSheetPresented = true
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "list.bullet")
                        }
                        .contentShape(Capsule())
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                        .glassEffect()
                    }

                    SegmentPicker()

                    Button {
                        // TODO: Add fetch
                    } label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    }
                    .padding(12)
                    .glassEffect()
                }
                .padding(.top, 60)
                .padding(.horizontal)

                Spacer()

                HStack {
                    Spacer()
                    MapUserLocationButton(scope: locationBtn)
                        .tint(.beaconOrange)
                        .foregroundStyle(.deepBlue)
                        .clipShape(Circle())
                        .padding(8)
                        .glassEffect()
                        .padding(.trailing, 16)
                        .padding(.bottom, 56)
                }
            }.ignoresSafeArea()
        }
        .mapScope(locationBtn)
        .onAppear {
            // Request permission
            locationManager.requestWhenInUseAuthorization()

            // Initialize map position from persisted values
            let region = MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: storedLat, longitude: storedLon),
                span: MKCoordinateSpan(latitudeDelta: storedSpanLat, longitudeDelta: storedSpanLon)
            )
            position = .region(region)
        }
        // Persist camera/region updates using Map's dedicated callback
        .onMapCameraChange(frequency: .continuous) { context in
            let region = context.region
            storedLat = region.center.latitude
            storedLon = region.center.longitude
            storedSpanLat = region.span.latitudeDelta
            storedSpanLon = region.span.longitudeDelta

            print("Saved map location -> center: (\(storedLat), \(storedLon)), span: (latDelta: \(storedSpanLat), lonDelta: \(storedSpanLon))")
        }
        .sheet(isPresented: $isSheetPresented) {
            VStack(spacing: 16) {
                PlacesListView()
            }
            .padding()
        }
    }
}

#Preview {
    MapView()
}
