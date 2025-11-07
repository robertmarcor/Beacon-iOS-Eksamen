//
//  KeyDecoder.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 03/11/2025.
//

import Foundation

enum Secrets{
    static var geoapifyAPIKey: String{
        guard let key = Bundle.main.infoDictionary?["GEOAPIFY_API_KEY"] as? String
        else{
            fatalError("Key not found in Secrets.xcconfig")
        }
        return key
        
    }
}
