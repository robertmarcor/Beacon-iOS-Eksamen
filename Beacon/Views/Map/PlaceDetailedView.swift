//
//  PlaceSheet.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import SwiftUI
import CoreLocation
import SwiftData
import MapKit

struct PlaceDetailedView: View {
    var place: Place
    
    @State private var isRatingView = false
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Title
                HStack{
                    Text(place.name)
                        .font(.title2.bold())
                        .foregroundStyle(.beaconOrange)
                    Spacer()
                }
                
                // Ratings
                HStack(spacing: 12) {
                    AverageRating(placeId: place.id)
                    Spacer()
                    Button("Give Rating"){
                        isRatingView = true
                    }
                    .padding(4)
                    .padding(.horizontal, 6)
                    .background(.beaconOrange)
                    .foregroundStyle(.white)
                    .clipShape(.capsule)
                }
                
                // Opening Hours
                if let hours = place.opening_hours, !hours.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack{
                        Text("Opening Hours")
                            .font(.footnote.bold())
                            .foregroundStyle(.secondary)
                        OpeningHoursBadge(place: place)
                        }
                        Text(hours
                            .replacingOccurrences(of: ";", with: "\n")
                            .components(separatedBy: .newlines)
                            .map { $0.trimmingCharacters(in: .whitespaces) }
                            .joined(separator: "\n"))
                            .font(.subheadline)
                    }
                }
                
                // Contact
                VStack(alignment: .leading){
                    if let phone = place.phone, !phone.isEmpty{
                        Text("Phone: \(phone)")
                    }
                    if let email = place.email, !email.isEmpty{
                        Text("Email: \(email)")
                    }
                        
                }
                
                // Address
                if let address = place.address, !address.isEmpty {
                    Label(address, systemImage: "mappin.and.ellipse")
                        .font(.subheadline)
                        .foregroundStyle(.beaconOrange)
                        .lineLimit(3)
                }
                if let website = place.website, let url = URL(string: website) {
                    Link(destination: url) {
                        Label("Website", systemImage: "link")
                    }
                    .font(.caption)
                }
                // Coordinates Section
                VStack(alignment: .leading, spacing: 4) {
                    Text("Coordinates")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                    Text("\(place.lat), \(place.lon)")
                        .font(.caption.monospacedDigit())
                        .foregroundStyle(.secondary)
                    Button{
                        openInAppleMaps(latitude: place.lat, longitude: place.lon, name: place.name)
                    }
                    label: {
                        Label("Open in Apple Maps", systemImage: "map")
                            .underline()
                    }
                        
                }
            }
            .padding(30)
        }
        .sheet(isPresented: $isRatingView) {
            PlaceRatingView(placeId: place.id, placeName: place.name)
                .presentationDetents([.height(220)])
        }
    }
    
    
    // xcode was complaing because of iOS mismatch, so asked AI to generate a fix
    func openInAppleMaps(latitude: Double, longitude: Double, name: String) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        if #available(iOS 18.0, macOS 15.0, watchOS 11.0, tvOS 18.0, visionOS 2.0, *) {
            // New API: avoid deprecated MKMapItem(placemark:)
            let mapItem = MKMapItem(location: location, address: nil)
            mapItem.name = name
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        } else {
            // Fallback for older OS versions
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let placemark = MKPlacemark(coordinate: coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = name
            mapItem.openInMaps(launchOptions: [
                MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
            ])
        }
    }}

#Preview {
    PlaceDetailedView(place: Place(
        id: "a1",
        name: "Sample Place",
        lat: 60.3913,
        lon: 5.3221,
        address: "Bryggen, 5003 Bergen, Norway",
        website: "https://www.website.com",
        distance: 50,
        opening_hours: "Mo-Fr 09:00-20:00; Sa 09:00-18:00",
        phone: "99 99 99 99",
        email: "example@mail.com",
        categories: ["Cafe"],
    ))
}
