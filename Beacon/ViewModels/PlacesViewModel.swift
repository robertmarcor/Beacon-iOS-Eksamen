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
import SwiftData
import MapKit

@MainActor // required
final class PlacesViewModel: ObservableObject {
    @Published var places: [Place] = []
    @Published var region: MKCoordinateRegion?
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var fetchTime: Date = .now
    
    @Published var center = CLLocationCoordinate2D.oslo
    @Published var categories: [String] = ["catering.cafe"]
    @Published var radius: Int = 1000
    @Published var limit: Int = 10
    
    // SwiftData
    private var context: ModelContext?
    @Published private(set) var favorites: [FavoritePlace] = []
    
    func setModelContext(_ context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Networking
    
    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            places = try await PlacesAPI.fetchPlaces(
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
        fetchTime = .now
        zoomToFit()
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
    func zoomToFit()
    {
        guard !places.isEmpty else { return }
        
        let minLat = places.map { $0.lat }.min()!
        let maxLat = places.map { $0.lat }.max()!
        let minLon = places.map { $0.lon }.min()!
        let maxLon = places.map { $0.lon }.max()!
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        // Zoom
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1,
            longitudeDelta: (maxLon - minLon) * 2,
        )
        
        region = MKCoordinateRegion(center: center, span: span)
    }
    
    func setCenter(_ coord: CLLocationCoordinate2D) {
        center = coord
        print(String(format: "Center set %.5f, %.5f", center.latitude, center.longitude))
    }
    
    func setCategory(_ single: String) { categories = [single] }
    func clear() { places = []; errorMessage = nil }
    
    // MARK: - Favorites (SwiftData)
    
    func isFavorite(_ place: Place) -> Bool {
        favorites.contains(where: { $0.id == place.id })
    }
    
    func toggleFavorite(_ place: Place) {
        // To make sure we are using the same container
        guard let context else {
            assertionFailure("ModelContext not set on PlacesViewModel. Call setModelContext(_:) from a View with @Environment(\\.modelContext).")
            return
        }
        if let existing = favorites.first(where: { $0.id == place.id }) {
            context.delete(existing)
        } else {
            let fav = FavoritePlace(from: place)
            context.insert(fav)
        }
        do {
            try context.save()
        } catch {
            print("Favorites save failed: \(error)")
        }
    }
}
