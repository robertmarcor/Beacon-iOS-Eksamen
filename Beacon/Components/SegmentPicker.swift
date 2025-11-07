//
//  SegmentPicker.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import SwiftUI

enum PlaceType: String, CaseIterable {
    case restaurants = "Restaurants"
    case cafe = "Café"
    case hotels = "Hotels"
}

extension PlaceType {
    var geoapifyCategories: [String] {
        switch self {
        case .restaurants: return ["catering.restaurant"]
        case .cafe:        return ["catering.cafe"]
        case .hotels:      return ["accommodation.hotel"]
        }
    }
}

struct SegmentPicker: View {
    @Binding var selection: PlaceType
    
    var body: some View {
        VStack{
            HStack{
                Picker("Places", selection: $selection) {
                    Image(systemName: "fork.knife")
                        .renderingMode(.template)
                        .accessibilityLabel(Text(PlaceType.restaurants.rawValue))
                        .tag(PlaceType.restaurants)
                    
                    Image(systemName: "cup.and.heat.waves")
                        .renderingMode(.template)
                        .accessibilityLabel(Text(PlaceType.cafe.rawValue))
                        .tag(PlaceType.cafe)
                    
                    Image(systemName: "bed.double")
                        .renderingMode(.template)
                        .accessibilityLabel(Text(PlaceType.hotels.rawValue))
                        .tag(PlaceType.hotels)
                }
                .pickerStyle(.segmented)
                .onAppear {
                    // Custom Picker Styling
                    let seg = UISegmentedControl.appearance()
                    seg.selectedSegmentTintColor = UIColor(named: "DeepBlue")
                    seg.setTitleTextAttributes([.foregroundColor: UIColor.highlightOrange], for: .selected)
                    seg.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
                }
            }
            .padding(8)
            .glassEffect()
        }
    }
}

#Preview {
    SegmentPicker(selection: .constant(.restaurants))
}
