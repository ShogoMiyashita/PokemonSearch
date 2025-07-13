import Foundation

struct PokemonDetail: Equatable, Identifiable, Codable {
    let id: Int
    let name: String
    let types: [PokemonType]
    let abilities: [Ability]
    let moves: [Move]
    let sprites: Sprites
    let height: Int
    let weight: Int
}

struct PokemonType: Equatable, Codable {
    let slot: Int
    let type: TypeInfo
}

struct TypeInfo: Equatable, Codable {
    let name: String
    let url: String
}

struct Ability: Equatable, Codable {
    let slot: Int
    let ability: AbilityInfo
    let isHidden: Bool
    
    enum CodingKeys: String, CodingKey {
        case slot
        case ability
        case isHidden = "is_hidden"
    }
}

struct AbilityInfo: Equatable, Codable {
    let name: String
    let url: String
}

struct Move: Equatable, Codable {
    let move: MoveInfo
}

struct MoveInfo: Equatable, Codable {
    let name: String
    let url: String
}

struct Sprites: Equatable, Codable {
    let frontDefault: String?
    let frontShiny: String?
    let backDefault: String?
    let backShiny: String?
    
    enum CodingKeys: String, CodingKey {
        case frontDefault = "front_default"
        case frontShiny = "front_shiny"
        case backDefault = "back_default"
        case backShiny = "back_shiny"
    }
}