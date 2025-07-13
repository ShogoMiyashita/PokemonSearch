import Foundation

enum PokeAPIEndpoint: Endpoint {
    case pokemonList(limit: Int)
    case pokemonDetail(id: Int)
    case searchPokemon(limit: Int)
    
    var baseURL: String {
        "https://pokeapi.co/api/v2"
    }
    
    var path: String {
        switch self {
        case .pokemonList, .searchPokemon:
            return "/pokemon"
        case .pokemonDetail(let id):
            return "/pokemon/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .pokemonList, .pokemonDetail, .searchPokemon:
            return .GET
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .pokemonList(let limit), .searchPokemon(let limit):
            return ["limit": limit]
        case .pokemonDetail:
            return nil
        }
    }
}