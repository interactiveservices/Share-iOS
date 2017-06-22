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

//How to setup VK App
//1. Register Standalone app
//2. Add app sheme like vk{id} where id - is your app id. If id is 1111 scheme should be vk1111
//3.

extension Share {
    
    open class Vk: NSObject, Sharer {
        
        public typealias Item = ShareItem
        public typealias Sender = Vk
        public typealias ShareError = VkShareError
        
        open var authoriser:VkAuthoriser?
        open var presentingController:UIViewController?
        
        var objectToRetain:Vk?
        
        public init(authoriser:VkAuthoriser? = nil, presentingController:UIViewController? = nil){
            
            self.authoriser = authoriser
            self.presentingController = presentingController
            super.init()
            
        }
        
        convenience override init(){
            
            self.init(authoriser: nil)
        }
        
        deinit {
            print("Vk sharer finished:\(self)")
        }
        
        public func shareBy(item:Item, completion:((Completion)->Void)?) {
            
            self.completion = completion
            self.shareItem = item
            
            self.retainSelf()
            
            self.authIfNeeded(with: { _ in
                
                self.shareWhenAuthorised(item: item,
                                         completion: completion)

                
            }) { error in
                
                self.callCompletionWith( ShareResult.error(error) )
            }
            
        }
        
        open func getUserInfoWith(completion:@escaping ((UserData)->Void)) {
            
            self.authIfNeeded(with: { _ in
                
                let pictureRequest = VKRequest(method: "users.get",
                                               parameters: ["fields": ["first_name",
                                                                       "last_name",
                                                                       "photo_max",
                                                                       "photo_200",
                                                                       "photo_100",
                                                                       "photo_50",
                                                                       "email"]])
                
                pictureRequest?.execute(resultBlock: { result in
                    
                    guard var info = (result?.json as? [[String : Any]])?.first else {
                        
                        completion(UserData.error(VkShareError.other(NSError.unknownVkError())))
                        
                        return
                    }
                    
                    if let email = VKSdk.accessToken()?.email,
                        info["email"] == nil{
                        info["email"] = email
                    }
                    
                    completion(UserData.success(info))
                    
                }, errorBlock: { error in
                    
                    completion(UserData.error(VkShareError.other(error)))
                    
                })
                
            }) { error in
                
                completion(UserData.error(error))
                
            }
        }
        
        private func authIfNeeded(with success:@escaping (Void)->Void, failure:@escaping (VkShareError)->Void){

            self.retainSelf()

            switch (Share.VkAuthoriser.isAuthorised, authoriser){

            case (true, _):
                
                success()
                releaseSelf()
                
            case (_,.some(let authoriser)):

                authoriser.authorise{ result in

                    switch result {

                    case .success:
                        success()

                    case .failure(let error):
                        failure(error)
                        
                    }
                    self.releaseSelf()
                }
            case (_,nil):
                
                callCompletionWith(ShareResult.error(.isNotAuthorised))
                releaseSelf()
            }
        }
        
        public enum UserData {
            case error(ShareError)
            case success([String:Any])
        }
        
        public struct ShareItem {
            
            var text:String?
            var images:[UIImage]
            var link:(title:String?,url:URL)?
            
            public init(text: String? = nil, images: [UIImage] = [], link: (title:String?,url:URL)? = nil) {
                
                self.text = text
                self.images = images
                self.link = link
                
            }
            
        }
        
        public enum VkShareError {
            case userDeniedAccess
            case isNotAuthorised
            case authFailed(Error?)
            case other(Error?)
        }
        
        fileprivate var shareItem:Item!
        fileprivate var completion:((Completion)->Void)?
        
        fileprivate func shareWhenAuthorised(item:Item, completion:((Completion)->Void)?){
            
            let sharer = VKShareDialogController()
            
            sharer.text = item.text
            sharer.uploadImages = item.images.map{ image in
                
                let params = VKImageParameters()
                params.imageType = VKImageTypeJpg
                params.jpegQuality = 0.7
                
                return VKUploadImage(image: image,
                                     andParams: params)
            }
            if let link = item.link {
                sharer.shareLink = VKShareLink(title: link.title,
                                               link: link.url)
            }
            sharer.dismissAutomatically = true
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
            self.completion = nil
            self.releaseSelf()
        }
    }
}


extension Share.Vk:Retainer {
    
    typealias Retainee = Share.Vk
    
}

extension NSError {
    
    static func unknownVkError()->NSError
    {
        return NSError(domain: "Share.Vk", code: -2390523, userInfo: nil)
    }
}
