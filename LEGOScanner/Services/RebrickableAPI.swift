//
//  RebrickableAPI.swift
//  LEGOScanner
//
//  Created by Casey Tritt on 1/17/26.
//

import Foundation

class RebrickableAPI {
    static let shared = RebrickableAPI()
    
    private let baseURL = "https://rebrickable.com/api/v3"
    private let apiKey = "YOUR_REBRICKABLE_API_KEY" // Get from rebrickable.com
    
    private init() {}
    
    func getPartInfo(partNumber: String, completion: @escaping (Result<PartInfo, Error>) -> Void) {
        
        let urlString = "\(baseURL)/lego/parts/\(partNumber)/"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "RebrickableAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("key \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "RebrickableAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data returned from API"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let partInfo = try decoder.decode(PartInfo.self, from: data)
                completion(.success(partInfo))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func searchParts(query: String, completion: @escaping (Result<[PartInfo], Error>) -> Void) {
        
        let urlString = "\(baseURL)/lego/parts/?search=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "RebrickableAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("key \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "RebrickableAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(SearchResponse.self, from: data)
                completion(.success(response.results))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

struct PartInfo: Codable {
    let partNum: String
    let name: String
    let partCatId: Int?
    let partUri: String?
    let partImgUrl: String?
    
    var categoryName: String {
        // Map category IDs to names
        let categories: [Int: String] = [
            1: "Baseplate",
            3: "Brick",
            4: "Brick, Modified",
            11: "Plate",
            14: "Plate, Modified",
            15: "Slope",
            18: "Tile",
            26: "Minifig",
        ]
        return categories[partCatId ?? 0] ?? "Other"
    }
}

struct SearchResponse: Codable {
    let count: Int
    let results: [PartInfo]
}

