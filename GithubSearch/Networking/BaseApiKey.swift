//
//  BaseApiKey.swift
//  GithubSearch
//
//  Created by Victor on 2025/6/24.
//

protocol ApiKeyType {
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
