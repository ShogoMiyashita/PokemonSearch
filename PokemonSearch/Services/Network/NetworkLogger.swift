import Foundation

final class NetworkLogger {
    static func logRequest(_ endpoint: Endpoint) {
        print("[Network] \(endpoint.method.rawValue) \(endpoint.baseURL)\(endpoint.path)")
        if let parameters = endpoint.parameters, !parameters.isEmpty {
            print("[Network] Parameters: \(parameters)")
        }
    }
    
    static func logResponse(data: Data, response: URLResponse, endpoint: Endpoint) {
        if let httpResponse = response as? HTTPURLResponse {
            print("[Network] Response \(httpResponse.statusCode) - \(data.count) bytes")
        }
    }
    
    static func logError(_ error: Error, endpoint: Endpoint) {
        print("[Network] Error for \(endpoint.path): \(error.localizedDescription)")
    }
}
