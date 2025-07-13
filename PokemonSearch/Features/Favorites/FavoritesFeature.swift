import Foundation
import ComposableArchitecture

@Reducer
struct FavoritesFeature {
    @ObservableState
    struct State: Equatable {
        var favorites: [PokemonDetail] = []
        var isLoading = false
        var error: String?
        var selectedPokemon: PokemonDetailFeature.State?
    }
    
    enum Action: Equatable {
        case onAppear
        case loadFavorites
        case favoritesResponse(TaskResult<[PokemonDetail]>)
        case pokemonTapped(PokemonDetail)
        case pokemonDetail(PokemonDetailFeature.Action)
        case dismissDetail
        case deleteFavorite(Int)
        case deleteFavoriteResponse(TaskResult<DeleteFavoriteSuccess>)
    }
    
    @Dependency(\.favoritesClient) var favoritesClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .send(.loadFavorites)
                
            case .loadFavorites:
                state.isLoading = true
                state.error = nil
                return .run { send in
                    await send(.favoritesResponse(
                        TaskResult { try await favoritesClient.load() }
                    ))
                }
                
            case .favoritesResponse(.success(let favorites)):
                state.isLoading = false
                state.favorites = favorites
                return .none
                
            case .favoritesResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case .pokemonTapped(let pokemon):
                state.selectedPokemon = PokemonDetailFeature.State(pokemonId: pokemon.id)
                return .none
                
            case .pokemonDetail(.deleteFavoriteResponse(.success)):
                return .send(.loadFavorites)
                
            case .pokemonDetail:
                return .none
                
            case .dismissDetail:
                state.selectedPokemon = nil
                return .none
                
            case .deleteFavorite(let id):
                return .run { send in
                    await send(.deleteFavoriteResponse(
                        TaskResult { 
                            try await favoritesClient.delete(id)
                            return DeleteFavoriteSuccess()
                        }
                    ))
                }
                
            case .deleteFavoriteResponse(.success):
                return .send(.loadFavorites)
                
            case .deleteFavoriteResponse(.failure(let error)):
                state.error = error.localizedDescription
                return .none
            }
        }
        .ifLet(\.selectedPokemon, action: \.pokemonDetail) {
            PokemonDetailFeature()
        }
    }
}