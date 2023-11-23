//
//  PokemonViewModel.swift
//  Dex3
//
//  Created by Atacan Sevim on 6.11.2023.
//

import Foundation

@MainActor
final class PokemonViewModel: ObservableObject {
    enum Status {
        case notStarted
        case fetching
        case success
        case failed(error: Error)
    }
    
    @Published private(set) var status: Status = .notStarted
    
    private let controller: FetchControllerProtocol
    
    init(controller: FetchControllerProtocol) {
        self.controller = controller
        Task {
            await getPokemons()
        }
    }
    
    private func getPokemons() async {
        status = .fetching
        
        do {
            guard var pokedex = try await controller.fetchAllPokemon() else {
                status = .success
                return
            }
            
            pokedex.sort { $0.id < $1.id }
            
            for pokemon in pokedex {
                var newPokemon = Pokemon(context: PersistenceController.shared.container.viewContext)
                assignToCoreDataElement(to: &newPokemon, from: pokemon)
                try PersistenceController.shared.container.viewContext.save()
            }
            
            status = .success
        } catch {
            status = .failed(error: error)
        }
    }
    
    private func assignToCoreDataElement(to newPokemon: inout Pokemon, from pokemon: TempPokemon) {
        newPokemon.id = Int16(pokemon.id)
        newPokemon.name = pokemon.name
        newPokemon.types = pokemon.types
        newPokemon.hp = Int16(pokemon.hp)
        newPokemon.attack = Int16(pokemon.attack)
        newPokemon.defense = Int16(pokemon.defense)
        newPokemon.specialAttack = Int16(pokemon.specialAttack)
        newPokemon.specialDefense = Int16(pokemon.specialDefense)
        newPokemon.speed = Int16(pokemon.speed)
        newPokemon.sprite = pokemon.sprite
        newPokemon.shiny = pokemon.shiny
        newPokemon.favorite = false
    }
}
