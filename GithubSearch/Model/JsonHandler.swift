//
//  JsonHandler.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/11.
//

import Foundation

class JsonHandler {
    static func parserData<T: Decodable>(data: Data, modelType: T.Type) throws -> T {
        let jsonDecode = try JSONDecoder().decode(T.self, from: data)
        return jsonDecode
    }
}
