import Foundation
import ComposableArchitecture

@Reducer
struct PokemonDetailFeature {
    @ObservableState
    struct State: Equatable, Identifiable {
        let pokemonId: Int
        var id: Int { pokemonId }
        var pokemonDetail: PokemonDetail?
        var isLoading = false
        var error: String?
        var isFavorite = false
    }
    
    enum Action: Equatable {
        case onAppear
        case fetchPokemonDetail
        case pokemonDetailResponse(TaskResult<PokemonDetail>)
        case checkFavoriteStatus
        case favoriteStatusResponse(TaskResult<Bool>)
        case toggleFavorite
        case saveFavoriteResponse(TaskResult<SaveFavoriteSuccess>)
        case deleteFavoriteResponse(TaskResult<DeleteFavoriteSuccess>)
    }
    
    @Dependency(\.pokeAPIClient) var pokeAPIClient
    @Dependency(\.favoritesClient) var favoritesClient
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .send(.fetchPokemonDetail),
                    .send(.checkFavoriteStatus)
                )
                
            case .fetchPokemonDetail:
                state.isLoading = true
                state.error = nil
                return .run { [id = state.pokemonId] send in
                    await send(.pokemonDetailResponse(
                        TaskResult { try await pokeAPIClient.fetchPokemonDetail(id) }
                    ))
                }
                
            case .pokemonDetailResponse(.success(let detail)):
                state.isLoading = false
                state.pokemonDetail = detail
                return .none
                
            case .pokemonDetailResponse(.failure(let error)):
                state.isLoading = false
                state.error = error.localizedDescription
                return .none
                
            case .checkFavoriteStatus:
                return .run { [id = state.pokemonId] send in
                    await send(.favoriteStatusResponse(
                        TaskResult { try await favoritesClient.isFavorite(id) }
                    ))
                }
                
            case .favoriteStatusResponse(.success(let isFavorite)):
                state.isFavorite = isFavorite
                return .none
                
            case .favoriteStatusResponse(.failure):
                return .none
                
            case .toggleFavorite:
                guard let detail = state.pokemonDetail else { return .none }
                
                if state.isFavorite {
                    return .run { [id = detail.id] send in
                        await send(.deleteFavoriteResponse(
                            TaskResult { 
                                try await favoritesClient.delete(id)
                                return DeleteFavoriteSuccess()
                            }
                        ))
                    }
                } else {
                    return .run { send in
                        await send(.saveFavoriteResponse(
                            TaskResult { 
                                try await favoritesClient.save(detail)
                                return SaveFavoriteSuccess()
                            }
                        ))
                    }
                }
                
            case .saveFavoriteResponse(.success):
                state.isFavorite = true
                return .none
                
            case .saveFavoriteResponse(.failure):
                return .none
                
            case .deleteFavoriteResponse(.success):
                state.isFavorite = false
                return .none
                
            case .deleteFavoriteResponse(.failure):
                return .none
            }
        }
    }
}
