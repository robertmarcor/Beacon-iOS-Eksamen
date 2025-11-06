//
//  PlacesModel.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import CoreLocation

struct PlacesResponse: Decodable{
    let features: [Feature]
    
    struct Feature: Decodable {
        let properties: Properties
        let geometry: Geometry
    }
    
    struct Properties: Decodable {
        let place_id: String
        let name: String?
        let formatted: String?
        let categories: [String]?
        let opening_hours: String?
        let website: String?
        let distance: Int
        let contact: Contact?
    }
    
    struct Contact: Decodable{
        let phone: String?
        let email: String?
    }

    struct Geometry: Decodable {
        let coordinates: [Double]
    }
}

// Our local Place model
struct Place: Identifiable, Codable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let address: String?
    let website: String?
    let distance: Int
    var opening_hours: String? = ""
    let phone: String?
    let email: String?
    let categories: [String]?
}

// For cleaner code since lon and lat are Doubles and not Coordinates
extension Place {
    var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lon)
    }
}
