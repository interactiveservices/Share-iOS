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
        public typealias Item = (activityItems:[Any], vc:UIViewController)
        public typealias Sender = Activity
        public typealias ShareError = Error
        
        
        public func shareBy(item:Item, completion:((Completion)->Void)? = nil){
            let vc = UIActivityViewController(activityItems: item.activityItems, applicationActivities: nil)
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
                    completion?(sharer:self,item:item,result:ShareResult<Error>.error(NSError()))
                }
            }
            item.vc.present(vc,animated:true,completion:nil)
        }
        
        public init() {
            
        }
        
    }
    
}
