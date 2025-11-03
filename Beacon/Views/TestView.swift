//
//  TestView.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import SwiftUI
import MapKit

struct TestView: View {
    private let locationManager = CLLocationManager()
    

    var body: some View {
        VStack{
            Map{
                
            }
            .onAppear{
                locationManager.requestWhenInUseAuthorization()
            }
            MapUserLocationButton()
        }
    }
}

#Preview {
    TestView()
}
