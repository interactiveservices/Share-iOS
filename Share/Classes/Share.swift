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
    static func shareBy(item:Item)
}

public class Share {
    
    
}
