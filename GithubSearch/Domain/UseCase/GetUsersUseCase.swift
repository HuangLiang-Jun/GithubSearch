//
//  GetUsersUseCase.swift
//  GithubSearch
//
//  Created by Victor on 2025/7/7.
//

import Foundation

final class SearchUsersUseCase {
    private let repository: SearchUserRepository
    
    init(repository: SearchUserRepository) {
        self.repository = repository
    }
    
    func execute(query: String, page: Int = 1) async throws -> Pagination<[User]> {
        return try await repository.fetchUsers(query: query, page: page)
    }
}
