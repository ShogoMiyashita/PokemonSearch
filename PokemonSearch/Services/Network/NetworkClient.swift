import Foundation

protocol NetworkClientProtocol {
    func request<T: Codable>(_ endpoint: Endpoint) async throws -> T
    func request(_ endpoint: Endpoint) async throws -> Data
}

struct NetworkClient: NetworkClientProtocol {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func request<T: Codable>(_ endpoint: Endpoint) async throws -> T {
        let data = try await request(endpoint)
        return try decode(data, to: T.self, endpoint: endpoint)
    }
    
    func request(_ endpoint: Endpoint) async throws -> Data {
        let request = try endpoint.urlRequest()
        
        NetworkLogger.logRequest(endpoint)
        
        do {
            let (data, response) = try await session.data(for: request)
            NetworkLogger.logResponse(data: data, response: response, endpoint: endpoint)
            
            try validateResponse(response)
            return data
        } catch {
            NetworkLogger.logError(error, endpoint: endpoint)
            throw NetworkError.requestFailed(error)
        }
    }
    
    private func decode<T: Codable>(_ data: Data, to type: T.Type, endpoint: Endpoint) throws -> T {
        do {
            return try JSONDecoder().decode(type, from: data)
        } catch {
            NetworkLogger.logError(NetworkError.decodingFailed(error), endpoint: endpoint)
            throw NetworkError.decodingFailed(error)
        }
    }
    
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard 200...299 ~= httpResponse.statusCode else {
            throw NetworkError.serverError(httpResponse.statusCode)
        }
    }
}