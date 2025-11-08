//
//  FavoritePlaceModel.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 06/11/2025.
//
// Hindsight: would be to maybe just make favorites into a bool on
// place model instead of its own model

import Foundation
import SwiftData

@Model
final class FavoritePlace {
    // Use Place.id (Geoapify place_id) as primary identifier
    var id: String
    var name: String
    var lat: Double
    var lon: Double
    var address: String?
    var website: String?
    var distance: Int
    var opening_hours: String?
    var phone: String?
    var email: String?
    var categories: [String]?
    
    init(
        id: String,
        name: String,
        lat: Double,
        lon: Double,
        address: String?,
        website: String?,
        distance: Int,
        opening_hours: String?,
        phone: String?,
        email: String?,
        categories: [String]?
    ) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
        self.address = address
        self.website = website
        self.distance = distance
        self.opening_hours = opening_hours
        self.phone = phone
        self.email = email
        self.categories = categories
    }
}

extension FavoritePlace {
    convenience init(from place: Place) {
        self.init(
            id: place.id,
            name: place.name,
            lat: place.lat,
            lon: place.lon,
            address: place.address,
            website: place.website,
            distance: place.distance,
            opening_hours: place.opening_hours,
            phone: place.phone,
            email: place.email,
            categories: place.categories
        )
    }
}

