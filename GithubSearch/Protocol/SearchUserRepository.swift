//
//  UserRepository.swift
//  GithubSearch
//
//  Created by Victor on 2025/7/7.
//

import Foundation

protocol SearchUserRepository {
    func fetchUsers(query: String, page: Int) async throws -> Pagination<[User]>
}
