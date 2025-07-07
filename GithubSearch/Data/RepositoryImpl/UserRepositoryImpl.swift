//
//  UserRepositoryImpl.swift
//  GithubSearch
//
//  Created by Victor on 2025/7/7.
//

import Foundation

final class SearchUserRepositoryImpl: SearchUserRepository {
    
    private let searchService: SearchService
    
    init(searchService: SearchService) {
        self.searchService = searchService
    }
    
    func fetchUsers(query: String, page: Int) async throws -> Pagination<[User]> {
        return try await searchService.searchUsers(query: query, page: page)
    }
}
