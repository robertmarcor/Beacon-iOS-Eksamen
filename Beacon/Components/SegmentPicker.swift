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

struct SegmentPicker: View {
    @State private var selection: PlaceType = .restaurants
    
    init() {
        let seg = UISegmentedControl.appearance()
        seg.selectedSegmentTintColor = UIColor(named: "DeepBlue")
        seg.setTitleTextAttributes([.foregroundColor: UIColor.highlightOrange], for: .selected)
        seg.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
    }

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
            }
            .padding(8)
            .glassEffect()
        }
    }
}

#Preview {
    SegmentPicker()
}
