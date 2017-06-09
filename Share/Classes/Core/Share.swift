//
//  Share.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 05/06/2017.
//
//

import Foundation

public protocol Sharer {
    
    associatedtype Item
    associatedtype Sender
    associatedtype ShareError
    
    typealias Completion = (sharer:Sender, item:Item, result:ShareResult<ShareError>)
    
    func shareBy(item:Item, completion:((Completion)->Void)?)
}

public enum ShareResult<ErrorType> {
    case cancel
    case success
    case error(ErrorType)
}

public struct Share {
    
    
}
