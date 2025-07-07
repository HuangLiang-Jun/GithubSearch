//
//  ApiKey.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation

enum SearchApiKey: ApiKeyType {
    
    case searchUser
    
    init(_ apiKey: SearchApiKey) {
        self = apiKey
    }

    var httpMethod: HTTPMethod {
        switch self {
        case .searchUser: return .get
        }
    }
    
    var contentType: ContentType {
        switch self {
        case .searchUser: return .query
        }
    }
    
    var path: String {
        switch self {
        case .searchUser: return "search/users"
        }
    }
}
