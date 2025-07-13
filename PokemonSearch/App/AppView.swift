import SwiftUI
import ComposableArchitecture

struct AppView: View {
    let store: StoreOf<AppFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.selectedTab) { viewStore in
            TabView(selection: viewStore.binding(send: AppFeature.Action.tabSelected)) {
                PokemonListView(
                    store: store.scope(
                        state: \.pokemonList,
                        action: \.pokemonList
                    )
                )
                .tabItem {
                    Image(systemName: "list.bullet")
                    Text("Pokemon")
                }
                .tag(AppFeature.State.Tab.pokemonList)
                
                FavoritesView(
                    store: store.scope(
                        state: \.favorites,
                        action: \.favorites
                    )
                )
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(AppFeature.State.Tab.favorites)
            }
        }
    }
}

#Preview {
    AppView(
        store: Store(initialState: AppFeature.State()) {
            AppFeature()
        }
    )
}