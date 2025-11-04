//
//  GeoapifyPlaces.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import Foundation

// MARK: Setter opp response modellen for å ta imot JSON fra geoapify
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
    }

    struct Geometry: Decodable {
        let coordinates: [Double]
    }
}

// MARK: Vår modell for hva vi trenger
struct Place: Identifiable {
    let id: String
    let name: String
    let lat: Double
    let lon: Double
    let address: String?
}

// MARK: Fetch og map data til vår modell
enum Geoapify{
    // Henter nøkkelen vår
    static var apiKey: String { Secrets.geoapifyAPIKey}
    
    // Sette opp URL med nødvendige parameter og default verdier
    static func fetchPlaces(
        lon: Double,
        lat: Double,
        radius: Int = 1000,
        category: [String] = ["accomodation.hotel"],
        limit: Int = 10) async throws -> [Place]{
            // Bygge url
            var urlComps = URLComponents(string: "https://api.geoapify.com/v2/places")!
            urlComps.queryItems = [
                .init(name: "apiKey", value: apiKey),
                .init(name: "categories", value: category.joined(separator: ",")),
                .init(name: "filter", value: "circle:\(lon),\(lat),\(radius)"),
                .init(name: "bias", value: "proximity:\(lon),\(lat)"),
                .init(name: "limit", value: String(limit))
            ]
            guard let url = urlComps.url else { throw URLError(.badURL) }
            // Swift fetch, throw error if bad url
            let (data, response) = try await URLSession.shared.data(from: url)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            
            // decode and map the response to our place struct
            let dto = try JSONDecoder().decode(PlacesResponse.self, from: data)
            return dto.features.map { feature in
                let coords = feature.geometry.coordinates
                return Place(
                    id: feature.properties.place_id,
                    name: feature.properties.name ?? "Unnamed",
                    lat: coords.count > 1 ? coords[1] : 0,
                    lon: coords.first ?? 0,
                    address: feature.properties.formatted
                )
            }

        }
    
}
