import Foundation
import ComposableArchitecture

struct PokeAPIClient {
    var fetchPokemonList: @Sendable (Int) async throws -> PokemonListResponse
    var fetchPokemonDetail: @Sendable (Int) async throws -> PokemonDetail
    var searchPokemon: @Sendable (String) async throws -> [Pokemon]
    
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
        
        self.fetchPokemonList = { limit in
            try await networkClient.request(.pokemonList(limit: limit))
        }
        
        self.fetchPokemonDetail = { id in
            try await networkClient.request(.pokemonDetail(id: id))
        }
        
        self.searchPokemon = { query in
            let response: PokemonListResponse = try await networkClient.request(.searchPokemon(limit: 1000))
            return response.results.filter { pokemon in
                pokemon.name.lowercased().contains(query.lowercased())
            }
        }
    }
}

extension PokeAPIClient: DependencyKey {
    static let liveValue = PokeAPIClient()
    
    static let testValue = PokeAPIClient()
}

extension DependencyValues {
    var pokeAPIClient: PokeAPIClient {
        get { self[PokeAPIClient.self] }
        set { self[PokeAPIClient.self] = newValue }
    }
}
