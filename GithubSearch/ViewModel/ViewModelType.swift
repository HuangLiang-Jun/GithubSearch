//
//  ViewModelType.swift
//  GithubSearch
//
//  Created by Victor on 2022/2/10.
//

import Foundation

protocol ViewModelType: AnyObject {

    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
}
