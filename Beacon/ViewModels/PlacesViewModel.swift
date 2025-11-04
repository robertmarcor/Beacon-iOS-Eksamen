//
//  PlacesViewModel.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 04/11/2025.
//

// PlacesViewModel.swift
import Foundation
import CoreLocation
internal import Combine

@MainActor // required
final class PlacesViewModel: ObservableObject {
    // UI state
    @Published var places: [Place] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // simple inputs (you can expose setters or bind these from a view)
    @Published var center = CLLocationCoordinate2D(latitude: 59.9139, longitude: 10.7522) // Oslo default
    @Published var categories: [String] = ["catering.cafe"]
    @Published var radius: Int = 1000
    @Published var limit: Int = 5

    /// Main load entry. Safe to call from `.task {}` or a button.
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
        } catch {
            places = []
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    /// Convenience helpers (optional)
    func setCenter(_ coord: CLLocationCoordinate2D) { center = coord }
    func setCategory(_ single: String) { categories = [single] }
    func addCategory(_ c: String) { if !categories.contains(c) { categories.append(c) } }
    func clear() { places = []; errorMessage = nil }
}

