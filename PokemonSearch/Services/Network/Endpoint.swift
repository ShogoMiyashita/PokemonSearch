import Foundation

protocol Endpoint {
    var baseURL: String { get }
    var path: String { get }
    var method: HTTPMethod { get }
    var parameters: [String: Any]? { get }
    var headers: [String: String]? { get }
}

extension Endpoint {
    var headers: [String: String]? { nil }
    
    func urlRequest() throws -> URLRequest {
        guard let baseURL = URL(string: baseURL) else {
            throw NetworkError.invalidURL
        }
        
        let url = baseURL.appendingPathComponent(path)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        
        // GET/DELETEの場合はクエリパラメータとして追加
        if method == .GET || method == .DELETE, let parameters = parameters {
            components?.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: "\(value)")
            }
        }
        
        guard let finalURL = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = method.rawValue
        
        // POST/PUTの場合はJSONボディとして追加
        if method == .POST || method == .PUT, let parameters = parameters {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        }
        
        // カスタムヘッダーを追加
        headers?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        return request
    }
}