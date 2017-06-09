//
//  Instagram.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 07/06/2017.
//
//

import UIKit

///This implementation of sharing shows ActivityViewController
//in the end. but the difference is that when you will open
//it in instagram it will have preview of your post with 
//filters screen

//Warning! The class is not quite fair works when user share by
//notes or other service which is not redirects user to other app

extension Share {
    
    open class Instagram:NSObject, Sharer {
        
        public typealias Item = Asset
        public typealias Sender = Instagram
        public typealias ShareError = InstagramError
        
        public enum Asset {
            case image(UIImage, view:UIView)
            case photoIdentifier(String)
        }
        
        public enum InstagramError{
            case failedToOpenInstagram
            case usedOtherApp(String)
            case assetNotFound
        }
        
        open func shareBy(item:Item, completion:((Completion)->Void)? = nil)
        {
            self.shareItem = item
            self.completion = completion
            
            guard UIApplication.shared.canOpenURL(URL(string:"instagram://")!) else {
                self.callCompletion(.error(.failedToOpenInstagram))
                print("may be you forget to add instagram app to info.plist of your app like this:\n" +
                    "<key>LSApplicationQueriesSchemes</key>\n" +
                    "   <array>\n" +
                    "   <string>instagram</string>\n" +
                    "</array>\n?\nOr running simulator?")
                return
            }
            switch item {
            case .photoIdentifier(let id):
                shareVia(photoID:id)
            case .image(let image, let vc):
                shareVia(image:image, from:vc)
            }
        }
        
        private func shareVia(image:UIImage, from view:UIView){

            retainSelf()
            
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(type(of: self).willResignActive),
                                                   name: Notification.Name.UIApplicationWillResignActive,
                                                   object: nil)
            
            let saveImagePath = NSTemporaryDirectory() + "/instagramshare.igo"
            let imageData = UIImageJPEGRepresentation(image,0.7)!
            (imageData as NSData).write(toFile: saveImagePath, atomically: true)
            assert(FileManager.default.fileExists(atPath: saveImagePath))
            
            let imageURL = URL(fileURLWithPath: saveImagePath)
            
            let docController  = DocController()
            docController.url = imageURL
            docController.uti = "com.instagram.exclusivegram"
            docController.url = imageURL
            docController.delegate = self
            
            docController.presentOpenInMenu(from: CGRect.zero, in: view, animated: true)
            
            self.docController = docController
        }
        
        private func shareVia(photoID:String){
            
            let u = "instagram://library?LocalIdentifier=" + photoID
            let url = URL(string: u)!
            UIApplication.shared.openURL(url)
            
            self.callCompletion( .success)
            
            return
        }
        
        @objc private func willResignActive(){
            print("Looks like app is inactive. Suggest that app was forwarded to other app to share")
            self.callCompletion(.success)
            self.tearDown()
        }
        
        var objectToRetain:Instagram?
        fileprivate var shareItem:Item!
        fileprivate var completion:((Completion)->Void)?
        fileprivate var docController:UIDocumentInteractionController?
        
        fileprivate func callCompletion(_ result:ShareResult<InstagramError>){
            self.completion?((sharer:self,
                              item:self.shareItem,
                              result:result))
        }
        
        func tearDown(){
            self.docController?.delegate = nil
            self.completion = nil
            self.releaseSelf()
        }
        
        deinit {
            self.callCompletion(.cancel)
            NotificationCenter.default.removeObserver(self)
        }
    }
    
}

extension Share.Instagram: Retainer, UIDocumentInteractionControllerDelegate {
    typealias Retainee = Share.Instagram
    
    public func documentInteractionController(_ controller: UIDocumentInteractionController, willBeginSendingToApplication application: String?) {
        if application?.contains("instagram") ?? false{
            self.callCompletion(.success)
        }
        else {
            self.callCompletion(.error(.usedOtherApp(application ?? "unknown bundle id")))
        }
        self.tearDown()
    }
    
    public func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController) {
        self.callCompletion(.cancel)
        self.tearDown()
    }
}

class DocController:UIDocumentInteractionController, UIGestureRecognizerDelegate {
    
    override func responds(to aSelector: Selector!) -> Bool {
        print("asked to responds to:\(aSelector)")
        return super.responds(to: aSelector)
    }
    
    override func actionSheetCancel(_ actionSheet: UIActionSheet) {
        super.actionSheetCancel(actionSheet)
    }
    
    override func actionSheet(_ actionSheet: UIActionSheet, didDismissWithButtonIndex buttonIndex: Int) {
        super.actionSheet(actionSheet, didDismissWithButtonIndex: buttonIndex)
    }
    
    override func presentPreview(animated: Bool) -> Bool {
        print(#function)
        return super.presentPreview(animated: animated)
    }
    
    override func willPresent(_ actionSheet: UIActionSheet) {
        super.willPresent(actionSheet)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
}
