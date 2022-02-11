//
//  ApiKey.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation

protocol ApiKey {
    var httpMethod: HTTPMethod { get }
    var contentType: ContentType { get }
    var path: String { get }
}

enum HTTPMethod: String {
    case delete = "DELETE"
    case post = "POST"
    case get = "GET"
    case put = "PUT"
}

enum ContentType {
    case query
}

enum SearchApiKey: ApiKey {
    
    case User
    
    init(_ apiKey: SearchApiKey) {
        self = apiKey
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .User: return .get
        }
    }
    
    var contentType: ContentType {
        switch self {
        case .User: return .query
        }
    }
    
    var path: String {
        switch self {
        case .User: return "search/users"
        }
    }
}
