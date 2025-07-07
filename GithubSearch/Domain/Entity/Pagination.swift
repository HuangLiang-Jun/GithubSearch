//
//  Pagination.swift
//  GithubSearch
//
//  Created by Victor on 2025/6/24.
//

import Foundation

struct Pagination<T: Codable>: Codable {
    /// if has next page will return true
    let incompleteResults: Bool
    let items: T
    enum CodingKeys: String, CodingKey {
        case items
        case incompleteResults
    }
}
