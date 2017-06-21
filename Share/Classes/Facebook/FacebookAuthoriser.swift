//
//  Facebook.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 13/06/2017.
//
//

import Foundation
import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

extension Share {
    
    
    open class FacebookAuthoriser:NSObject, UIApplicationDelegate {
        
        public enum FacebookError {
            case failed(Error?)   //something happennd
            case rejected(Error?) //user denied
        }
        
        public class var isAuthorised:Bool {
            return FBSDKAccessToken.current() != nil
        }
        
        let permissions: [String]
        
        private lazy var loginManager:FBSDKLoginManager =  {
            
            let manager = FBSDKLoginManager()
            FBSDKProfile.enableUpdates(onAccessTokenChange: true)
            
            return manager
            
        }()
        
        public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                                                                         didFinishLaunchingWithOptions: launchOptions)
        }
        
        public func applicationDidBecomeActive(_ application: UIApplication) {
            FBSDKAppEvents.activateApp()
        }
        
        public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application, open:url,
                                                                         sourceApplication:sourceApplication,
                                                                         annotation:annotation)
        }
        
        public init(permissions:[String] = ["public_profile","email"]){
            
            self.permissions = permissions
            
            super.init()
            
        }
        
        open func authWith(success:@escaping(Void)->Void, failure:@escaping(FacebookError)->Void){
            
            FBSDKLoginManager.renewSystemCredentials { renewResult, error in
                
                switch (renewResult, error)
                {
                    
                case (.renewed, _):  success()
                    
                default: FBSDKAccessToken.refreshCurrentAccessToken({ connection, data, error in
                    
                    if error == nil {
                       success()
                        return
                    }
                    
                    self.loginManager.logIn(withReadPermissions: self.permissions,
                                            from: nil,
                                            handler: { result, error in
                                                
                                                switch (result, error){
                                                    
                                                case (.some(let result), _) where result.isCancelled == false:
                                                    success()
                                                    
                                                default:
                                                    failure(Share.FacebookAuthoriser.FacebookError.failed(error ?? NSError()))
                                                    
                                                }
                    })
                })
                    
                }
            }
        }
    }    
}
