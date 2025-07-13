import Foundation

struct Pokemon: Equatable, Identifiable, Codable {
    let id: Int
    let name: String
    let url: String
    
    init(id: Int, name: String, url: String) {
        self.id = id
        self.name = name
        self.url = url
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.url = try container.decode(String.self, forKey: .url)
        
        if let idFromURL = Self.extractIdFromURL(url) {
            self.id = idFromURL
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Could not extract ID from URL: \(url)"
                )
            )
        }
    }
    
    private static func extractIdFromURL(_ url: String) -> Int? {
        let components = url.split(separator: "/").filter { !$0.isEmpty }
        guard let lastComponent = components.last else { return nil }
        return Int(lastComponent)
    }
}

struct PokemonListResponse: Codable, Equatable{
    let count: Int
    let next: String?
    let previous: String?
    let results: [Pokemon]
}
