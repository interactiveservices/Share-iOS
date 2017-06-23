//
//  File.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 07/06/2017.
//
//

import Foundation
import UIKit

extension Share {
    
    public struct Activity:Sharer {
        public typealias Item = [Any]
        public typealias Sender = Activity
        public typealias ShareError = Error
        
        public var presentingController:UIViewController?
        
        public func shareBy(item:Item, completion:((Completion)->Void)? = nil){
            
            let vc = UIActivityViewController(activityItems: item, applicationActivities: nil)
            vc.completionWithItemsHandler = { (_,finished,_,error) in
                switch (finished,error)
                {
                case (true, _):
                    completion?(sharer:self,item:item,result:ShareResult<Error>.success)
                case (false, nil):
                    completion?(sharer:self,item:item,result:ShareResult<Error>.cancel)
                case (_,.some(let error)):
                    completion?(sharer:self,item:item,result:ShareResult<Error>.error(error))
                default:
                    completion?(sharer:self,item:item,result:ShareResult<Error>.error(NSError.unknownBaseError()))
                }
            }
            
            UIViewController.share_present(viewController: vc,
                                           from: self.presentingController)
        }
        
        public init(presentingController:UIViewController? = nil) {
            self.presentingController = presentingController
        }
        
    }
    
}

extension NSError {
    
    static func unknownBaseError()->NSError
    {
        return NSError(domain: "Share.Base", code: -2390523, userInfo: nil)
    }
}
