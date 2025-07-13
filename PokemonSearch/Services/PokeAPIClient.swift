import Foundation
import ComposableArchitecture

struct PokeAPIClient {
    var fetchPokemonList: @Sendable (Int) async throws -> PokemonListResponse
    var fetchPokemonDetail: @Sendable (Int) async throws -> PokemonDetail
    var searchPokemon: @Sendable (String) async throws -> [Pokemon]
}

extension PokeAPIClient: DependencyKey {
    static let liveValue = PokeAPIClient(
        fetchPokemonList: { limit in
            let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=\(limit)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(PokemonListResponse.self, from: data)
        },
        fetchPokemonDetail: { id in
            let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(id)")!
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(PokemonDetail.self, from: data)
        },
        searchPokemon: { query in
            let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1000")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(PokemonListResponse.self, from: data)
            return response.results.filter { pokemon in
                pokemon.name.lowercased().contains(query.lowercased())
            }
        }
    )
    
    static let testValue = PokeAPIClient(
        fetchPokemonList: { _ in
            PokemonListResponse(
                count: 1,
                next: nil,
                previous: nil,
                results: [
                    Pokemon(id: 1, name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
                ]
            )
        },
        fetchPokemonDetail: { _ in
            PokemonDetail(
                id: 1,
                name: "bulbasaur",
                types: [PokemonType(slot: 1, type: TypeInfo(name: "grass", url: ""))],
                abilities: [Ability(slot: 1, ability: AbilityInfo(name: "overgrow", url: ""), isHidden: false)],
                moves: [Move(move: MoveInfo(name: "tackle", url: ""))],
                sprites: Sprites(frontDefault: nil, frontShiny: nil, backDefault: nil, backShiny: nil),
                height: 7,
                weight: 69
            )
        },
        searchPokemon: { _ in
            [Pokemon(id: 1, name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")]
        }
    )
}

extension DependencyValues {
    var pokeAPIClient: PokeAPIClient {
        get { self[PokeAPIClient.self] }
        set { self[PokeAPIClient.self] = newValue }
    }
}