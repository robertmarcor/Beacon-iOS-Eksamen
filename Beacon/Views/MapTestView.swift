//
//  MapTestView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 04/11/2025.
//

import SwiftUI
import MapKit

struct MapTestView: View {
    private let bergen = CLLocationCoordinate2D(latitude: 60.39299, longitude: 5.32415)
    @State private var camera: MapCameraPosition
    init() {
        _camera = State(
            initialValue: .region(
                MKCoordinateRegion(
                    center: bergen,
                    span: .init(latitudeDelta: 0.03, longitudeDelta: 0.03)
                )
            )
        )
    }
    @State private var centerText: String = ""
    var body: some View {
        VStack{
            Text(centerText)
            Map(position: $camera){
                
            }
            .onMapCameraChange { context in
                let c = context.region.center
                centerText = String(format: "%f %f",c.latitude, c.longitude)
            }
        }
    }
}

#Preview {
    MapTestView()
}
