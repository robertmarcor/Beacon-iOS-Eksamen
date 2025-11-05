//
//  PlaceSheet.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import SwiftUI
import CoreLocation

struct PlaceSheet: View {
    let place: Place
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack{
                    Text(place.name)
                        .font(.title2.bold())
                        .foregroundStyle(.beaconOrange)
                    Spacer()
                }
                HStack(spacing: 2) {
                    let rating = place.averageRating
                    ForEach(0..<5) { i in
                        let value = Double(i) + 1
                        Image(systemName:
                            rating >= value
                            ? "star.fill"
                            : (rating >= value - 0.5 ? "star.leadinghalf.filled" : "star")
                        )
                        .foregroundStyle(.yellow)
                    }
                }
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
                }
            }
            .padding(30)
        }
    }
}

#Preview {
    PlaceSheet(place: Place(
        id: "preview-id",
        name: "Sample Place",
        lat: 60.3913,
        lon: 5.3221,
        address: "Bryggen, 5003 Bergen, Norway",
        website: "https://www.website.com",
        distance: 50,
        opening_hours: "Mo-Fr 09:00-20:00; Sa 09:00-18:00",
        phone: "99 99 99 99",
        email: "example@mail.com",
        myRating: .init(ratings: [4.3,1,3]),
    ))
}
