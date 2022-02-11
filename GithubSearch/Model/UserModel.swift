//
//  UserModel.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation

struct UsersModel: Codable {
    let items: [UserModel]
}

struct UserModel: Codable {
    let name: String
    private let avatarUrlString: String
    
    var avatarURL: URL? {
        return URL(string: avatarUrlString)
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "login"
        case avatarUrlString = "avatar_url"
    }
    
    init(name: String, avatarUrlString: String) {
        self.name = name
        self.avatarUrlString = avatarUrlString
    }
}
