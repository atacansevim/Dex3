//
//  ContentView.swift
//  Dex3
//
//  Created by Atacan Sevim on 6.11.2023.
//

import SwiftUI
import CoreData

struct ContentView: View {
  
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        animation: .default)
    private var pokemons: FetchedResults<Pokemon>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Pokemon.id, ascending: true)],
        predicate: NSPredicate(format: "favorite = %d", true),
        animation: .default)
    private var favoritePokemons: FetchedResults<Pokemon>
    
    @State var filterByFavorite = false
    @StateObject private var pokemonViewModel = PokemonViewModel(controller: FetchController())
    
    var body: some View {
        switch pokemonViewModel.status {
        case .success:
            NavigationStack {
                List {
                    ForEach(filterByFavorite ? favoritePokemons : pokemons) { pokemon in
                        NavigationLink(value: pokemon) {
                            AsyncImage(url: pokemon.sprite) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 100, height: 100)
                            
                            Text("\(pokemon.name!.capitalized)")
                            
                            if pokemon.favorite {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                            }
                        }
                    }
                }
                .navigationTitle("Pokedex")
                .navigationDestination(for: Pokemon.self) { pokemon in
                    PokemonDetail()
                        .environmentObject(pokemon)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            withAnimation {
                                filterByFavorite.toggle()
                            }
                            
                        }, label: {
                            Label("Filter by filter", systemImage: filterByFavorite ? "star.fill" : "star")
                        })
                        .font(.title)
                        .foregroundStyle(.yellow)
                    }
                }
            }
        default:
            ProgressView()
        }
    }
}


#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
