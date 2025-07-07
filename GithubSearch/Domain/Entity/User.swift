//
//  UserModel.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation

struct User: Hashable, Codable {
    let id: Int
    let name: String
    private let avatarUrlString: String
    
    var avatarUrl: URL? {
        return URL(string: avatarUrlString)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name = "login"
        case avatarUrlString = "avatarUrl"
    }
}
