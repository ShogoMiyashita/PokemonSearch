import Foundation
import ComposableArchitecture

@Reducer
struct PokemonListFeature {
    @ObservableState
    struct State: Equatable {
        var pokemon: [Pokemon] = []
        var searchText = ""
        var isLoading = false
        var error: String?
        var selectedPokemon: PokemonDetailFeature.State?
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchPokemonList
        case pokemonListResponse(TaskResult<PokemonListResponse>)
        case searchTextChanged(String)
        case searchPokemon(String)
        case searchResponse(TaskResult<[Pokemon]>)
        case pokemonTapped(Pokemon)
        case pokemonDetail(PokemonDetailFeature.Action)
        case dismissDetail
    }
    
    @Dependency(\.pokeAPIClient) var pokeAPIClient
    @Dependency(\.mainQueue) var mainQueue
    
    private enum CancelID { case search }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                guard state.pokemon.isEmpty else { return .none }
                return .send(.fetchPokemonList)
                
            case .fetchPokemonList:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    await send(.pokemonListResponse(
                        TaskResult { try await pokeAPIClient.fetchPokemonList(151) }
                    ))
                }
                
            case .pokemonListResponse(.success(let response)):
                state.isLoading = false
                state.pokemon = response.results
                return .none
                
            case .pokemonListResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case .searchTextChanged(let text):
                state.searchText = text
                if text.isEmpty {
                    return .send(.fetchPokemonList)
                } else {
                    return .send(.searchPokemon(text))
                        .debounce(id: CancelID.search, for: 0.3, scheduler: mainQueue)
                }
                
            case .searchPokemon(let query):
                guard !query.isEmpty else { return .none }
                state.isLoading = true
                return .run { send in
                    await send(.searchResponse(
                        TaskResult { try await pokeAPIClient.searchPokemon(query) }
                    ))
                }
                
            case .searchResponse(.success(let pokemon)):
                state.isLoading = false
                state.pokemon = pokemon
                return .none
                
            case .searchResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case .pokemonTapped(let pokemon):
                state.selectedPokemon = PokemonDetailFeature.State(pokemonId: pokemon.id)
                return .none
                
            case .pokemonDetail:
                return .none
                
            case .dismissDetail:
                state.selectedPokemon = nil
                return .none
            }
        }
        .ifLet(\.selectedPokemon, action: \.pokemonDetail) {
            PokemonDetailFeature()
        }
    }
}