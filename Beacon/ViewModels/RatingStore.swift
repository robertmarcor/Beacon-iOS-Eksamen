//
//  RatingViewModel.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 06/11/2025.
//

import Foundation
import SwiftData
import SwiftUI
import Combine

@MainActor
final class RatingStore: ObservableObject {
    
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    func addRating(id: String, name:String ,value: Double) {
        context.insert(Rating(id: id, name: name, value: value))
        do {
            try context.save()
            print("Value saved successfully: {id:\(id), value:\(value)}")
        } catch {
            print("Save failed: \(error)")
        }
    }
    
    func deleteRatings(ratings: [Rating]) {
        ratings.forEach { item in
            context.delete(item)
        }
        do {
            try context.save()
        } catch {
            print("Delete save failed: \(error)")
        }
    }
}
