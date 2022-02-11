//
//  Networking.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation

class Networking {
    private static let baseURL = "https://api.github.com"
    
    static func request(apiKey: ApiKey, parameter: [String: Any]?, completion: ((Data?, URLResponse?, Error?) -> Void)?) {
        let url = "\(baseURL)/\(apiKey.path)"
        guard let requestUrl = URL(string: url) else { return }
        
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
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            completion?(data, response, error)
        }.resume()
    }
}
