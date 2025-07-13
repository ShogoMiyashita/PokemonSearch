import SwiftUI
import ComposableArchitecture

struct PokemonListView: View {
    let store: StoreOf<PokemonListFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.self) { viewStore in
            NavigationStack {
                VStack {
                    SearchBar(
                        text: viewStore.binding(
                            get: \.searchText,
                            send: PokemonListFeature.Action.searchTextChanged
                        )
                    )
                    
                    if viewStore.isLoading {
                        ProgressView("Loading...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewStore.error {
                        ErrorView(
                            message: error,
                            retry: { viewStore.send(.fetchPokemonList) }
                        )
                    } else {
                        List(viewStore.pokemon) { pokemon in
                            PokemonRow(pokemon: pokemon) {
                                viewStore.send(.pokemonTapped(pokemon))
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Pokemon")
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .sheet(
                    item: viewStore.binding(
                        get: \.selectedPokemon,
                        send: { _ in .dismissDetail }
                    )
                ) { _ in
                    if let store = store.scope(state: \.selectedPokemon, action: \.pokemonDetail) {
                        NavigationStack {
                            PokemonDetailView(store: store)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .navigationBarTrailing) {
                                        Button("Done") {
                                            viewStore.send(.dismissDetail)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search Pokemon", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Error")
                .font(.headline)
            Text(message)
                .multilineTextAlignment(.center)
            Button("Retry", action: retry)
                .buttonStyle(.bordered)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

//#Preview {
//    PokemonListView(
//        store: Store(initialState: PokemonListFeature.State()) {
//            PokemonListFeature()
//        }
//    )
//}
