//
//  AutocompleteAPI.swift
//  Beacon
//
//  Created by Robert Marco Ramberg on 07/11/2025.
//

import Foundation
import Combine

// MainActor because it will update our searchfield with suggestions
@MainActor final class AutocompleteModel: ObservableObject
{
    @Published var places: [SearchResults] = []
    @Published var message: String?
    
    @Published var fetchTime: Date = .now
    
    func fetchSearches(
        text: String,
        lon: Double,
        lat: Double,
        radius: Int = 1000,
        limit: Int = 10)
    async
    {
        let apiKey: String = Secrets.geoapifyAPIKey
        var address = URLComponents(string: "https://api.geoapify.com/v1/geocode/autocomplete?")!
        
        var queries = [URLQueryItem]()
        queries.append(URLQueryItem(name: "text", value: text))
        queries.append(URLQueryItem(name: "limit", value: "\(limit)"))
        queries.append(URLQueryItem(name: "filter", value: "circle:\(lon),\(lat),\(radius)"))
        queries.append(URLQueryItem(name: "format", value: "json"))
        queries.append(URLQueryItem(name: "apiKey", value: "\(apiKey)"))
        address.queryItems = queries
        
        guard let url = address.url else
        {
            message = "Ugyldig URL – sjekk parametrene."
            return
        }
        
        do
        {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else
            {
                throw URLError(.badServerResponse)
            }
            
            guard (200...299).contains(httpResponse.statusCode) else
            {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            let responseData = try decoder.decode(SearchResponse.self, from: data)
            
            places = responseData.results
            
            message = """
      ⚠️ Vellykket nedlasting av data.
      🛜 Lastet ned \(data.count) Byte
      """
        }
        catch
        {
            message = """
      Feil ved henting fra Geoapify: \(error.localizedDescription)
      Kontroller internettforbindelsen og prøv igjen.
      """
        }
    }
}
