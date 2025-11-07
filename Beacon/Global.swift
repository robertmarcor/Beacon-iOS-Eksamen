//
//  Globals.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//
import MapKit
import SwiftUI

let mockPlaces: [Place] = [
    .init(
        id: "1",
        name: "Peppes Pizza - Ole Bulls Plass",
        lat: 60.391722,
        lon: 5.324276,
        address: "Nedre Ole Bulls plass, 5015 Bergen",
        website: "https://www.peppes.no",
        distance: 6,
        opening_hours: "Mo-We 11:00-23:00; Th-Sa 11:00-24:00; Su 12:00-23:00",
        phone: "90904412",
        email: "mail@exmaple.com",
        categories: ["TestCat"],
    ),
    
        .init(
            id: "2",
            name: "TGI Friday's",
            lat: 60.391370,
            lon: 5.323895,
            address: "Nedre Ole Bulls plass, 5015 Bergen",
            website: "https://fridays.no",
            distance: 49,
            opening_hours: "Mo 11:30-23:30; Tu-Th 11:30-00:30; Fr-Sa 11:30-01:30; Su 12:00-01:30",
            phone: "90904412",
            email: "mail@exmaple.com",
            categories: ["TestCat"],
        ),
    
        .init(
            id: "3",
            name: "Los Tacos",
            lat: 60.391201,
            lon: 5.323766,
            address: "Olav Kyrres gate, 5015 Bergen",
            website: "https://lostacos.no",
            distance: 69,
            opening_hours: "Su-Th 11:00-23:00, Fr-Sa 11:00-04:00",
            phone: "90904412",
            email: "mail@exmaple.com",
            categories: ["TestCat"],
        ),
    
        .init(
            id: "4",
            name: "Boccone",
            lat: 60.391426,
            lon: 5.322885,
            address: "Torggaten, 5015 Bergen",
            website: "https://boccone.no",
            distance: 85,
            opening_hours: "Mo-Th 15:00-22:00; Fr 15:00-22:00; Sa 12:00-23:00; Su 15:00-22:00",
            phone: "90904412",
            email: "mail@exmaple.com",
            categories: ["TestCat"],
        ),
]

extension CLLocationCoordinate2D
{
    static let bergen = CLLocationCoordinate2D(latitude: 60.39299, longitude: 5.32415)
    static let oslo = CLLocationCoordinate2D(latitude: 59.9111, longitude: 10.7503)
}


