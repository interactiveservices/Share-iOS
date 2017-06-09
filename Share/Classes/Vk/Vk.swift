//
//  Vk.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 08/06/2017.
//
//

import Foundation
import UIKit
import VK_ios_sdk

extension Share {
    
    public class Vk: NSObject, Sharer {
        
        public typealias Item = ShareItem
        public typealias Sender = Vk
        public typealias ShareError = VkShareError
        
        var authoriser:VkAuthoriser?
        var presentingController:UIViewController?
        
        init(authoriser:VkAuthoriser? = nil, presentingController:UIViewController? = nil){
            self.authoriser = authoriser
            self.presentingController = presentingController
            super.init()
        }
        
        convenience override init(){
            self.init(authoriser: nil)
        }
        
        public func shareBy(item:Item, completion:((Completion)->Void)?) {
            
            self.completion = completion
            
            switch (Share.VkAuthoriser.isAuthorised, authoriser)
            {
                
            case (true, _):
                self.shareWhenAuthorised(item: item,
                                         completion: completion)
                
            case (_,.some(let authoriser)):
                
                authoriser.authorise{ result in
                    
                    switch result
                    {
                    case .success:
                        self.shareWhenAuthorised(item: item,
                                                 completion: completion)
                        
                    case .failure(let error):
                        self.callCompletionWith(ShareResult.error(error))
                    }
                }
                
            case (_,nil):
                callCompletionWith( ShareResult<VkShareError>.error(.isNotAuthorised))
            }
            
        }
        
        
        public struct ShareItem {
            var text:String?
            var images:[UIImage]
            var link:(title:String?,url:URL)
            public init(text: String?, images: [UIImage], link: (title:String?,url:URL)) {
                self.text = text
                self.images = images
                self.link = link
            }
            
        }
        
        public enum VkShareError {
            case userDeniedAccess
            case isNotAuthorised
            case authFailed(Error?)
        }
        
        fileprivate var shareItem:Item!
        fileprivate var completion:((Completion)->Void)?
        
        fileprivate func shareWhenAuthorised(item:Item, completion:((Completion)->Void)?){
            let sharer = VKShareDialogController()
            sharer.text = item.text
            sharer.uploadImages = item.images
            sharer.shareLink = VKShareLink(title: item.link.title,
                                           link: item.link.url)
            sharer.completionHandler = { handler in
                switch handler.1
                {
                case .done: self.callCompletionWith(.success)
                case .cancelled: self.callCompletionWith(.cancel)
                }
            }
            let vc = self.presentingController ?? UIViewController.share_topViewController()
            vc?.present(sharer,
                        animated: true,
                        completion: nil)
        }
        
        fileprivate func callCompletionWith(_ result:ShareResult<VkShareError>){
            self.completion?((sharer: self,
                              item: self.shareItem,
                              result: result))
        }
    }
    
    //Before calling sharing dialog you should authorise your app using this class
    
    public class VkAuthoriser:NSObject, UIApplicationDelegate {
        
        enum AuthResult {
            case success
            case failure(Share.Vk.VkShareError)
        }
        
        typealias AuthCompletion = (AuthResult)->Void
        
        private var permissions:[String]
        
        public class var isAuthorised:Bool {
            return VKSdk.isLoggedIn()
        }
        
        typealias authSuccess = (Void)->Void
        typealias authFailure = (VKAuthorizationResult)->Void
        
        init(key:String, permissions:[String] = [VK_PER_EMAIL]){
            self.permissions = permissions
            super.init()
            let instance = VKSdk.initialize(withAppId: key)
            instance?.register(self)
            wakeUp()
        }
        
        private var completions = [AuthCompletion]()
        
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
        
        //Mark: - Private
        
        private func wakeUp(){
            
            VKSdk.wakeUpSession(self.permissions) { state, error in
                
                switch state
                {
                case .authorized: self.callSuccess()
                case .initialized: assert(self.completions.count == 0); break//just do nothing
                case .external, .safariInApp, .pending, .webview: break
                case .error, .unknown:
                    self.callFailure(with: Share.Vk.VkShareError.authFailed(error))
                }
            }
        }
        
        fileprivate func authorise(_ completion:@escaping AuthCompletion){
            self.completions.append(completion)
            if VkAuthoriser.isAuthorised {
                callSuccess()
                return
            }
            VKSdk.authorize(self.permissions)
        }
        
        private func callSuccess(){
            self.completions.forEach{ block in
                block(.success)
            }
            self.completions.removeAll()
        }
        
        private func callFailure(with error:Share.Vk.VkShareError){
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
        print("VK Auth finished with :\(result)")
        
        switch result.state
        {
        case .authorized:
            print("URA")
        case .initialized:
            print("Vk just woken up. Will process further")
        default:
            print("Ooops")
        }
        //TODO: Add auth with getting mail
    }
    
    public func vkSdkUserAuthorizationFailed() {
        print("failed to authorise in VK")
    }
    
    public func vkSdkAuthorizationStateUpdated(with result: VKAuthorizationResult!) {
        print("auth state did change to: \(result?.state ?? .unknown)")
    }
    
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
