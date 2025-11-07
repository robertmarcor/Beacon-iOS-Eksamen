//
//  SearchModel.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 07/11/2025.
//

import Foundation

struct SearchResponse: Decodable
{
    let results: [SearchResults]
}

struct SearchResults: Decodable, Identifiable
{
    var id: String
    {
        place_id ?? UUID().uuidString
    }
    
    let name: String
    let street: String?
    let lon: Double?
    let lat: Double?
    let place_id: String?
    
    // Added: Geoapify category (e.g., "catering.restaurant", "catering.cafe", "accommodation.hotel")
    let category: String?
}

