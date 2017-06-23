//
//  AppDelegate.swift
//  Share
//
//  Created by nikolay.shubenkov@gmail.com on 06/05/2017.
//  Copyright (c) 2017 nikolay.shubenkov@gmail.com. All rights reserved.
//

import UIKit
import Share
import FacebookShare

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {

    static let vkKey = "6067711"
    
    static var delegate:AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    var window: UIWindow?
    
    var vkAuthorizer:Share.VkAuthoriser!
    
    var facebookAuthorizer = Share.FacebookAuthoriser(permissions: ["public_profile","email","user_friends","user_posts"])
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        vkAuthorizer = Share.VkAuthoriser(key: AppDelegate.vkKey)        

        _ = facebookAuthorizer.application(application,
                                           didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if #available(iOS 9.0, *) {
            return application(app,
                               open: url,
                               sourceApplication: (options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String) ?? "",
                               annotation: (options[UIApplicationOpenURLOptionsKey.annotation] as? String) ?? "")
        } else {
            return true
        }
        
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {

        if vkAuthorizer.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return  true
        }
        
        if facebookAuthorizer.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) {
            return true
        }
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        vkAuthorizer.applicationDidBecomeActive(application)
        facebookAuthorizer.applicationDidBecomeActive(application)
        
    }

}

