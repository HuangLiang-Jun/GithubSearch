//
//  APIServices.swift
//  GithubSearch
//
//  Created by Victor on 2025/6/24.
//

import Foundation

class APIServices {
    private static let defaultDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }()
    
    static let searchService = SearchService(defaultDecoder: defaultDecoder)
}
