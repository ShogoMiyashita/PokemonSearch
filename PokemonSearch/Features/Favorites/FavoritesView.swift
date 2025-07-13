import SwiftUI
import ComposableArchitecture

struct FavoritesView: View {
    let store: StoreOf<FavoritesFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.self) { viewStore in
            NavigationStack {
                VStack {
                    if viewStore.isLoading {
                        ProgressView("Loading favorites...")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewStore.error {
                        ErrorView(
                            message: error,
                            retry: { viewStore.send(.loadFavorites) }
                        )
                    } else if viewStore.favorites.isEmpty {
                        EmptyFavoritesView()
                    } else {
                        List {
                            ForEach(viewStore.favorites) { pokemon in
                                FavoriteRow(pokemon: pokemon) {
                                    viewStore.send(.pokemonTapped(pokemon))
                                }
                                .swipeActions(edge: .trailing) {
                                    Button("Delete") {
                                        viewStore.send(.deleteFavorite(pokemon.id))
                                    }
                                    .tint(.red)
                                }
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Favorites")
                .onAppear {
                    viewStore.send(.onAppear)
                }
                .sheet(
                    item: viewStore.binding(
                        get: \.selectedPokemon,
                        send: { _ in .dismissDetail }
                    )
                ) { _ in
                    if let store = store.scope(
                        state: \.selectedPokemon,
                        action: \.pokemonDetail
                    ) {
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

struct FavoriteRow: View {
    let pokemon: PokemonDetail
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                AsyncImage(url: spriteURL) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } placeholder: {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .frame(width: 64, height: 64)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(pokemon.name.capitalized)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("#\(pokemon.id)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        ForEach(pokemon.types.prefix(2), id: \.slot) { type in
                            TypeBadge(typeName: type.type.name)
                        }
                    }
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var spriteURL: URL? {
        if let frontDefault = pokemon.sprites.frontDefault {
            return URL(string: frontDefault)
        }
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")
    }
}

struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Favorites Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add Pokemon to your favorites by tapping the heart icon in the detail view")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    FavoritesView(
        store: Store(initialState: FavoritesFeature.State()) {
            FavoritesFeature()
        }
    )
}
