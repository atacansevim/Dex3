//
//  FetchController.swift
//  Dex3
//
//  Created by Atacan Sevim on 6.11.2023.
//

import Foundation
import CoreData

protocol FetchControllerProtocol {
    func fetchAllPokemon() async throws -> [TempPokemon]?
    func fetchPokemon(from url: URL) async throws -> TempPokemon
    func havePokemon() -> Bool
}

class FetchController: FetchControllerProtocol {
    enum NetworkError: Error {
        case badUrl, badResponse
    }
    
    private let baseUrl = URL(string: "https://pokeapi.co/api/v2/pokemon/")!
    
    func fetchAllPokemon() async throws -> [TempPokemon]? {
        if havePokemon() {
            return nil
        }
        
        var allPokemon: [TempPokemon] = []
        var fetchComponents = URLComponents(url: baseUrl, resolvingAgainstBaseURL: true)
        fetchComponents?.queryItems = [URLQueryItem(name: "limit", value: "386")]
        
        guard let fetchUrl = fetchComponents?.url else {
            throw NetworkError.badUrl
        }
        
        let (data, response) = try await URLSession.shared.data(from: fetchUrl)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        guard let pokeDictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                , let pokedex = pokeDictionary["results"] as? [[String: String]] else {
            throw NetworkError.badResponse
        }
        
        for pokemon in pokedex {
            if let url = pokemon["url"] {
                allPokemon.append(try await fetchPokemon(from: URL(string: url)!))
            }
        }
            
        return allPokemon
    }
    
    func fetchPokemon(from url: URL) async throws -> TempPokemon {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        do {
            let tempPokemon =   try JSONDecoder().decode(TempPokemon.self, from: data)
            print("\(tempPokemon.id): \(tempPokemon.name)")
            return tempPokemon
        } catch {
            throw NetworkError.badResponse
        }
    }
    
    func havePokemon() -> Bool {
        let content = PersistenceController.shared.container.newBackgroundContext()
        
        let fetchRequest: NSFetchRequest<Pokemon> = Pokemon.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id IN %@", [1, 386])
        
        do {
            let checkPokemon = try content.fetch(fetchRequest)
            
            return checkPokemon.count == 2
        } catch {
            print("FetchFailed: \(error)")
            return false
        }
    }
}
