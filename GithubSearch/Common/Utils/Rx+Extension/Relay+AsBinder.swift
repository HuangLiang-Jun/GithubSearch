//
//  File.swift
//  GithubSearch
//
//  Created by Victor on 2025/6/24.
//

import RxSwift
import RxCocoa

extension PublishRelay {
    func asBinder() -> Binder<Element> {
       return Binder<Element>(self) { relay, e in
            relay.accept(e)
        }
    }
}

extension BehaviorRelay {
    func asBinder() -> Binder<Element> {
        return Binder<Element>(self) { relay, e in
            relay.accept(e)
        }
    }
}

