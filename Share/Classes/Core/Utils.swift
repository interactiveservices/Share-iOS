//
//  Utils.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 08/06/2017.
//
//

import UIKit

extension UIViewController {

    static func share_present(viewController:UIViewController, from parent:UIViewController? = nil){
    
        let vc = parent ?? self.share_topViewController()
        assert(vc != nil)
    
        vc?.present(viewController, animated: true, completion: nil)
    }
    
    static func share_topViewController()->UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    func share_topViewController()->UIViewController? {
        switch self {
            
        case let splitView as UISplitViewController:
            return splitView.viewControllers.last?.share_topViewController() ?? self
            
        case let tabbar as UITabBarController:
            return tabbar.selectedViewController?.share_topViewController() ?? self
        
        case let navBar as UINavigationController:
            return navBar.topViewController?.share_topViewController() ?? self
            
        default:
            
            if let pvc = presentedViewController {
                return pvc.share_topViewController()
            }
            if let child = childViewControllers.last {
                return child.share_topViewController()
            }
            return self
        }
    }
}

extension Collection {
    func share_prettyJSONString() -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
            guard let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) else {
                print("Can't create string with data.:\(self)")
                return "{}"
            }
            return jsonString
        } catch let parseError {
            print("json serialization error: \(parseError)")
            return "{}"
        }
    }
}
