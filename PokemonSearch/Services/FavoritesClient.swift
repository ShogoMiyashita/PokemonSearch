import Foundation
import ComposableArchitecture

struct FavoritesClient {
    var save: @Sendable (PokemonDetail) async throws -> Void
    var load: @Sendable () async throws -> [PokemonDetail]
    var delete: @Sendable (Int) async throws -> Void
    var isFavorite: @Sendable (Int) async throws -> Bool
}

struct DeleteFavoriteSuccess: Equatable {}

extension FavoritesClient: DependencyKey {
    static let liveValue = FavoritesClient(
        save: { pokemon in
            var favorites = try await loadFavorites()
            if !favorites.contains(where: { $0.id == pokemon.id }) {
                favorites.append(pokemon)
                try await saveFavorites(favorites)
            }
        },
        load: {
            try await loadFavorites()
        },
        delete: { id in
            var favorites = try await loadFavorites()
            favorites.removeAll { $0.id == id }
            try await saveFavorites(favorites)
        },
        isFavorite: { id in
            let favorites = try await loadFavorites()
            return favorites.contains { $0.id == id }
        }
    )
    
    static let testValue = FavoritesClient(
        save: { _ in },
        load: { [] },
        delete: { _ in },
        isFavorite: { _ in false }
    )
}

private func loadFavorites() async throws -> [PokemonDetail] {
    guard let data = UserDefaults.standard.data(forKey: "favorites") else {
        return []
    }
    return try JSONDecoder().decode([PokemonDetail].self, from: data)
}

private func saveFavorites(_ favorites: [PokemonDetail]) async throws {
    let data = try JSONEncoder().encode(favorites)
    UserDefaults.standard.set(data, forKey: "favorites")
}

extension DependencyValues {
    var favoritesClient: FavoritesClient {
        get { self[FavoritesClient.self] }
        set { self[FavoritesClient.self] = newValue }
    }
}
