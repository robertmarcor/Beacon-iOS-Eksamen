//
//  PlacesViewModel.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 04/11/2025.
//

import SwiftUI
import Foundation
import CoreLocation
import Combine

@MainActor // required
final class PlacesViewModel: ObservableObject {
    // UI state
    @Published var places: [Place] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    @AppStorage("cachedPlaces") private var cachedPlacesData: Data?

    @Published var center = CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522)
    @Published var categories: [String] = ["catering.cafe"]
    @Published var radius: Int = 1000
    @Published var limit: Int = 10
    
    init() {
        if let data = cachedPlacesData,
           let decoded = try? JSONDecoder().decode([Place].self, from: data) {
            self.places = decoded
        } else {
            print("No cached places found")
        }
    }
    
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            places = try await Geoapify.fetchPlaces(
                lon: center.longitude,
                lat: center.latitude,
                radius: radius,
                category: categories,
                limit: limit
            )
            if let data = cachedPlacesData,
               let decoded = try? JSONDecoder().decode([Place].self, from: data) {
                self.places = decoded
                print("✅ Loaded cached places (\(decoded.count)):")
            }


        } catch {
            places = []
            errorMessage = error.localizedDescription
        }
        isLoading = false
        print(String(
            format: "Fetched %d places [%@] at %.5f, %.5f  radius:%d  limit:%d",
            places.count,
            categories.joined(separator: ","),
            center.latitude,
            center.longitude,
            radius,
            limit
        ))

    }

    func setCenter(_ coord: CLLocationCoordinate2D) {
        center = coord
        print(String(format: "Center set %.5f, %.5f", center.latitude, center.longitude))
    }
    func setCategory(_ single: String) { categories = [single] }
    func clear() { places = []; errorMessage = nil }
}

