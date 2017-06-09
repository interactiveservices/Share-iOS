//
//  AppDelegate.swift
//  Share
//
//  Created by nikolay.shubenkov@gmail.com on 06/05/2017.
//  Copyright (c) 2017 nikolay.shubenkov@gmail.com. All rights reserved.
//

import UIKit
import Share

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    static let vkKey = ""
    
    var window: UIWindow?
    
    lazy var vkAuthorizer:Share.VkAuthoriser = {
        return Share.VkAuthoriser(key: AppDelegate.vkKey)
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if #available(iOS 9.0, *) {
            _ = vkAuthorizer.application(app, open: url, options: options)
        } else {
            // Fallback on earlier versions
        }
        return true
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        _ = vkAuthorizer.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        vkAuthorizer.applicationDidBecomeActive(application)
    }

}

