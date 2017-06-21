//
//  VkAuthoriser.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 13/06/2017.
//
//

import Foundation
import VK_ios_sdk

extension Share {
    //Before calling sharing dialog you should authorise your app using this class
    
    open class VkAuthoriser:NSObject, UIApplicationDelegate {
        
        public class var isAuthorised:Bool {
            
            return VKSdk.isLoggedIn()
            
        }
        
        public init(key:String, permissions:[String] = [VK_PER_EMAIL,VK_PER_WALL,VK_PER_PHOTOS]){
            
            self.permissions = permissions
            super.init()
            let instance = VKSdk.initialize(withAppId: key)
            instance?.register(self)
            instance?.uiDelegate = self
            wakeUp()
        }
        
        public enum AuthResult {
            
            case success
            case failure(Share.Vk.VkShareError)
            
        }
        
        typealias authSuccess = (Void)->Void
        typealias authFailure = (VKAuthorizationResult)->Void
        
        public typealias AuthCompletion = (AuthResult)->Void
        
        
        open func authorise(_ completion:@escaping AuthCompletion){
            
            self.completions.append(completion)
            
            if VkAuthoriser.isAuthorised {
                
                callSuccess()
                return
            }
            
            VKSdk.authorize(self.permissions)
        }
        
        public private(set) var permissions:[String]
        private var completions = [AuthCompletion]()
        
        //MARK: - AppDelegate
        
        public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
            
            if #available(iOS 9.0, *) {
                
                if let source = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String {
                    
                    return VKSdk.processOpen(url,
                                             fromApplication: source)
                }
            }
            return false
        }
        
        public func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
            
            return VKSdk.processOpen(url, fromApplication: sourceApplication)
            
        }
        
        public func applicationDidBecomeActive(_ application: UIApplication) {
            
            wakeUp()
        }
        
        //Mark: - Private
        
        private func wakeUp(){
            
            VKSdk.wakeUpSession(self.permissions) { state, error in
                
                switch state {
                    
                case .authorized: self.callSuccess()
                    
                case .initialized: break//just do nothing
                    
                case .external, .safariInApp, .pending, .webview: break
                    
                case .error, .unknown:
                    self.callFailure(with: Share.Vk.VkShareError.authFailed(error))
                }
            }
        }
        
        fileprivate func callSuccess(){
            
            self.completions.forEach{ block in
                block(.success)
            }
            self.completions.removeAll()
            
        }
        
        fileprivate func callFailure(with error:Share.Vk.VkShareError){
            
            self.completions.forEach{ block in
                block(AuthResult.failure(error))
            }
            self.completions.removeAll()
            
        }
    }
}

extension Share.VkAuthoriser: VKSdkDelegate, VKSdkUIDelegate {
    
    //MARK: - SDK Delegate
    
    public func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        
        print("VK Auth finished with :\(result.state)")
        
        switch result.state
        {
        case .authorized:
            self.callSuccess()
            
        case .initialized, .pending, .safariInApp, .webview, .external:
            print("Vk just woken up. Will process further")
            
        default:
            self.callFailure(with: .authFailed(nil))
            print("Ooops. Failed to authorize")
        }
        //TODO: Add auth with getting mail
    }
    
    public func vkSdkUserAuthorizationFailed() {
        
        print("failed to authorise in VK")
        self.callFailure(with: .authFailed(nil))
        
    }
    
//    public func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
//        
//        print("auth state did change to: \(result?.state ?? .unknown)")
//        if result.
//    }
    
    //MARK: - UI Delegate
    
    public func vkSdkShouldPresent(_ controller: UIViewController!) {
        
        assert(UIViewController.share_topViewController() != nil, "failed to get topMostViewController. It seems that no any viewController is presented in app currently")
        UIViewController.share_topViewController()?.present(controller, animated: true, completion: nil)
        
    }
    
    public func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        
        let vkController = VKCaptchaViewController.captchaControllerWithError(captchaError)
        vkController?.present(in: UIViewController.share_topViewController())
        
    }
}
