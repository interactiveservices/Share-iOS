//
//  Retainer.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 05/06/2017.
//
//

import Foundation


protocol Retainer:class {
    associatedtype Retainee
    var objectToRetain:Retainee? {set get}
}

extension Retainer {
    func retainSelf(){
        self.objectToRetain = self as? Retainee
    }
    
    func releaseSelf(){
        self.objectToRetain = nil
    }
}
