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
                    Menu {
                        Text("Hello")
                        Text("Hello")
                        Text("Hello")
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "list.bullet")
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 16)
                        .contentShape(Capsule())
                        .glassEffect()
                    }

                    SegmentPicker()

                    Button {
                        // TODO: Add your refresh/rotate action here
                    } label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                    }
                    .padding(8)
                    .glassEffect()
                }
                .padding(.top, 50)
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
        }
    }
}

#Preview {
    MapView()
}
