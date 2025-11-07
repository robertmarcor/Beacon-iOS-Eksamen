//
//  RatingEntry.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//

import Foundation
import SwiftData

@Model
final class Rating {
    var id: String
    var name: String
    var value: Double
    
    init(id: String, name: String, value: Double) {
        self.id = id
        self.name = name
        self.value = value
    }
}
