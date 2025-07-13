import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var pokemonList = PokemonListFeature.State()
        var favorites = FavoritesFeature.State()
        var selectedTab = Tab.pokemonList
        
        enum Tab: CaseIterable {
            case pokemonList
            case favorites
        }
    }
    
    enum Action: Equatable {
        case tabSelected(State.Tab)
        case pokemonList(PokemonListFeature.Action)
        case favorites(FavoritesFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.pokemonList, action: \.pokemonList) {
            PokemonListFeature()
        }
        
        Scope(state: \.favorites, action: \.favorites) {
            FavoritesFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .tabSelected(let tab):
                state.selectedTab = tab
                return .none
                
            case .pokemonList:
                return .none
                
            case .favorites:
                return .none
            }
        }
    }
}