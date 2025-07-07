//
//  SearchApi.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation

class SearchService: BaseApiService<SearchApiKey> {
    func searchUsers(query: String, page: Int) async throws -> Pagination<[User]> {
        let parameter: [String: Any] = ["q": "\(query)+in:login",
                                        "page": page]
        return try await requestPagination(apiKey: .searchUser, parameter: parameter)
    }
}
