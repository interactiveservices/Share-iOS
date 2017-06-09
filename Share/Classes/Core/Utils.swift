//
//  Utils.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 08/06/2017.
//
//

import UIKit

extension UIViewController {

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
