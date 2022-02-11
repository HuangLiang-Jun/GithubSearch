//
//  SearchApi.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation

class SearchApi {
    static func searchUser(key: String, page: Int = 1, complectiom: @escaping (_ data: [UserModel]?, _ nextPage: Bool, _ error: Error?) -> ()) {
        let apiKey = SearchApiKey(.User)
        let parameter: [String: Any] = ["q": "\(key)+in:login",
                                        "page": page]
        Networking.request(apiKey: apiKey, parameter: parameter) { data, response, error in
            var nextpage = false
            if let error = error {
                complectiom(nil, nextpage, error)
                return
            }
            guard let data = data else { return }
            if ((response as? HTTPURLResponse)?.allHeaderFields["Link"] as? String)?.contains("rel=\"next\"") == true {
                nextpage = true
            }
            do {
                let data = try JsonHandler.parserData(data: data, modelType: UsersModel.self)
                complectiom(data.items, nextpage, nil)
            } catch {
                complectiom(nil, nextpage, error)
            }
        }
    }
}
