import SwiftUI

struct PokemonRow: View {
    let pokemon: Pokemon
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
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var spriteURL: URL? {
        URL(string: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png")
    }
}

#Preview {
    List {
        PokemonRow(
            pokemon: Pokemon(id: 1, name: "bulbasaur", url: "https://pokeapi.co/api/v2/pokemon/1/")
        ) {
            
        }
        
        PokemonRow(
            pokemon: Pokemon(id: 25, name: "pikachu", url: "https://pokeapi.co/api/v2/pokemon/25/")
        ) {
            
        }
    }
}