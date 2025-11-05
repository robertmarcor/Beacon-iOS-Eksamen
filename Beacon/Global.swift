//
//  Globals.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 05/11/2025.
//
import MapKit
import SwiftUI

let mockPlaces: [Place] = [
    .init(id: "1", name: "Peppes Pizza - Ole Bulls Plass", lat: 60.391722, lon: 5.324276,
          address: "Nedre Ole Bulls plass, 5015 Bergen", website: "https://www.peppes.no",
          distance: 6,
          opening_hours: "Mo-We 11:00-23:00; Th-Sa 11:00-24:00; Su 12:00-23:00", phone: "90904412", email: "mail@exmaple.com"),

    .init(id: "2", name: "TGI Friday's", lat: 60.391370, lon: 5.323895,
          address: "Nedre Ole Bulls plass, 5015 Bergen", website: "https://fridays.no",
          distance: 49,
          opening_hours: "Mo 11:30-23:30; Tu-Th 11:30-00:30; Fr-Sa 11:30-01:30; Su 12:00-01:30", phone: "90904412", email: "mail@exmaple.com"),

    .init(id: "3", name: "Los Tacos", lat: 60.391201, lon: 5.323766,
          address: "Olav Kyrres gate, 5015 Bergen", website: "https://lostacos.no",
          distance: 69,
          opening_hours: "Su-Th 11:00-23:00, Fr-Sa 11:00-04:00", phone: "90904412", email: "mail@exmaple.com"),

    .init(id: "4", name: "Boccone", lat: 60.391426, lon: 5.322885,
          address: "Torggaten, 5015 Bergen", website: "https://boccone.no",
          distance: 85,
          opening_hours: "Mo-Th 15:00-22:00; Fr 15:00-22:00; Sa 12:00-23:00; Su 15:00-22:00", phone: "90904412", email: "mail@exmaple.com"),

    .init(id: "5", name: "Olivia", lat: 60.391661, lon: 5.322693,
          address: "Torggaten, 5015 Bergen", website: "https://olivia.no",
          distance: 87,
          opening_hours: "Daily 12:00-23:00", phone: "90904412", email: "mail@exmaple.com"),

    .init(id: "6", name: "Villa Paradiso Ole Bull", lat: 60.392156, lon: 5.322790,
          address: "Torgallmenningen, 5013 Bergen", website: "https://villaparadiso.no",
          distance: 92,
          opening_hours: "Mo-Tu 12:00-21:00; We 12:00-21:30; Th-Sa 12:00-22:00; Su 13:00-20:00", phone: "90904412", email: "mail@exmaple.com"),

    .init(id: "7", name: "Bocca", lat: 60.392261, lon: 5.322256,
          address: "Øvre Ole Bulls plass, 5012 Bergen", website: "https://olebullscene.no",
          distance: 123,
          opening_hours: "Mo-Tu 11:00-02:00; We-Sa 11:00-03:30; Su 12:00-02:00", phone: "90904412", email: "mail@exmaple.com"),

    .init(id: "8", name: "Dråpen Vinbar", lat: 60.391594, lon: 5.322024,
          address: "Vaskerelvsmauet, 5015 Bergen", website: "https://draapenvinbar.no",
          distance: 125,
          opening_hours: "Mo-Th 16:00-01:00; Fr 16:00-02:30; Sa 13:00-02:30; Su 16:00-00:00", phone: "90904412", email: "mail@exmaple.com"),

    .init(id: "9", name: "Egon Bristol", lat: 60.392628, lon: 5.322656,
          address: "Markeveien, 5012 Bergen", website: "https://egon.no",
          distance: 130,
          opening_hours: "Mo-Sa 10:00-24:00; Su 11:00-23:00", phone: "90904412", email: "mail@exmaple.com"),

    .init(id: "10", name: "Holbergstuen", lat: 60.393005, lon: 5.324727,
          address: "Torgallmenningen, 5013 Bergen", website: "https://holbergstuen.no",
          distance: 140,
          opening_hours: "Mo-Fr 09:00-21:00; Sa 09:00-18:00", phone: "90904412", email: "mail@exmaple.com")
]



let bergen = CLLocationCoordinate2D(latitude: 60.39299, longitude: 5.32415)
