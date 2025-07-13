import SwiftUI
import ComposableArchitecture

struct PokemonDetailView: View {
    let store: StoreOf<PokemonDetailFeature>
    
    var body: some View {
        WithViewStore(store, observe: \.self) { viewStore in
            ScrollView {
                if viewStore.isLoading {
                    ProgressView("Loading...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .frame(minHeight: 400)
                } else if let error = viewStore.error {
                    ErrorView(
                        message: error,
                        retry: { viewStore.send(.fetchPokemonDetail) }
                    )
                } else if let pokemon = viewStore.pokemonDetail {
                    PokemonDetailContent(
                        pokemon: pokemon,
                        isFavorite: viewStore.isFavorite,
                        onFavoriteToggle: { viewStore.send(.toggleFavorite) }
                    )
                }
            }
            .navigationTitle(viewStore.pokemonDetail?.name.capitalized ?? "Pokemon")
            .onAppear {
                viewStore.send(.onAppear)
            }
        }
    }
}

struct PokemonDetailContent: View {
    let pokemon: PokemonDetail
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            PokemonImageSection(pokemon: pokemon)
            
            PokemonInfoSection(pokemon: pokemon)
            
            PokemonTypesSection(types: pokemon.types)
            
            PokemonAbilitiesSection(abilities: pokemon.abilities)
            
            PokemonMovesSection(moves: Array(pokemon.moves.prefix(5)))
            
            Spacer()
        }
        .padding()
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundColor(isFavorite ? .red : .gray)
                }
            }
        }
    }
}

struct PokemonImageSection: View {
    let pokemon: PokemonDetail
    
    var body: some View {
        AsyncImage(url: spriteURL) { image in
            image
                .resizable()
                .aspectRatio(contentMode: .fit)
        } placeholder: {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
        }
        .frame(width: 200, height: 200)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
    
    private var spriteURL: URL? {
        if let frontDefault = pokemon.sprites.frontDefault {
            return URL(string: frontDefault)
        }
        return URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")
    }
}

struct PokemonInfoSection: View {
    let pokemon: PokemonDetail
    
    var body: some View {
        VStack(spacing: 8) {
            Text("#\(pokemon.id)")
                .font(.title2)
                .foregroundColor(.secondary)
            
            HStack(spacing: 40) {
                VStack {
                    Text("\(pokemon.height)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Height")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(pokemon.weight)")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Weight")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
}

struct PokemonTypesSection: View {
    let types: [PokemonType]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Types")
                .font(.headline)
            
            HStack {
                ForEach(types, id: \.slot) { type in
                    TypeBadge(typeName: type.type.name)
                }
                Spacer()
            }
        }
    }
}

struct TypeBadge: View {
    let typeName: String
    
    var body: some View {
        Text(typeName.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(typeColor)
            .foregroundColor(.white)
            .cornerRadius(12)
    }
    
    private var typeColor: Color {
        switch typeName.lowercased() {
        case "fire": return .red
        case "water": return .blue
        case "grass": return .green
        case "electric": return .yellow
        case "psychic": return .purple
        case "ice": return .cyan
        case "dragon": return .indigo
        case "dark": return .black
        case "fairy": return .pink
        case "fighting": return .orange
        case "poison": return Color(red: 0.6, green: 0.2, blue: 0.8)
        case "ground": return .brown
        case "flying": return Color(red: 0.5, green: 0.8, blue: 1.0)
        case "bug": return Color(red: 0.6, green: 0.8, blue: 0.2)
        case "rock": return Color(red: 0.7, green: 0.6, blue: 0.3)
        case "ghost": return Color(red: 0.4, green: 0.3, blue: 0.6)
        case "steel": return .gray
        case "normal": return Color(red: 0.6, green: 0.6, blue: 0.6)
        default: return .gray
        }
    }
}

struct PokemonAbilitiesSection: View {
    let abilities: [Ability]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Abilities")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(abilities, id: \.slot) { ability in
                    HStack {
                        Text(ability.ability.name.capitalized)
                        if ability.isHidden {
                            Text("(Hidden)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                }
            }
        }
    }
}

struct PokemonMovesSection: View {
    let moves: [Move]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Moves (Top 5)")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(moves.enumerated()), id: \.offset) { index, move in
                    Text(move.move.name.capitalized)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetailView(
            store: Store(
                initialState: PokemonDetailFeature.State(pokemonId: 1)
            ) {
                PokemonDetailFeature()
            }
        )
    }
}