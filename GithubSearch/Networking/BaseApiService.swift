//
//  Networking.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation

class BaseApiService<ApiKey> where ApiKey: ApiKeyType {
    
    private let baseURL = AppConfiguration.ProductionServicer.githubBaseURL
    private let defaultDecoder: JSONDecoder
    
    init(defaultDecoder: JSONDecoder) {
        self.defaultDecoder = defaultDecoder
    }
    
    private func log(data: Data) {
        debugPrint("\n\(String(data: data, encoding: .utf8))")
    }
    
    func request<T: Codable>(apiKey: ApiKey, parameter: [String: Any]?) async throws -> T {
        let url = "\(baseURL)/\(apiKey.path)"
        let requestUrl = URL(string: url)!
        var request = URLRequest(url: requestUrl)
        request.timeoutInterval = 30
        request.httpMethod = apiKey.httpMethod.rawValue
        
        switch apiKey.contentType {
        case .query:
            if let parameter = parameter {
                var component = URLComponents(string: url)
                let queryItems: [URLQueryItem] = parameter.map({ URLQueryItem(name: $0.key, value: String(describing: $0.value)) })
                component?.queryItems = queryItems
                request.url = component?.url
            }
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        log(data: data)
        return try defaultDecoder.decode(T.self, from: data)
    }
    
    func requestPagination<T: Codable>(apiKey: ApiKey, parameter: [String: Any]?) async throws -> Pagination<T> {
        let url = "\(baseURL)/\(apiKey.path)"
        let requestUrl = URL(string: url)!
        var request = URLRequest(url: requestUrl)
        request.timeoutInterval = 30
        request.httpMethod = apiKey.httpMethod.rawValue
        
        switch apiKey.contentType {
        case .query:
            if let parameter = parameter {
                var component = URLComponents(string: url)
                let queryItems: [URLQueryItem] = parameter.map({ URLQueryItem(name: $0.key, value: String(describing: $0.value)) })
                component?.queryItems = queryItems
                request.url = component?.url
            }
        }
        
        let (data, _) = try await URLSession.shared.data(for: request)
        log(data: data)
        return try defaultDecoder.decode(Pagination<T>.self, from: data)
    }
}
