//
//  Instagram.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 07/06/2017.
//
//

import UIKit

extension Share {
    
    open class Instagram:NSObject, Sharer {
        
        public typealias Item = Asset
        public typealias Sender = Instagram
        public typealias ShareError = InstagramError
        
        public enum Asset {
            case image(UIImage)
            case photoIdentifier(String)
        }
        
        public enum InstagramError{
            case failedToOpenInstagram
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
            case .image(let image):
                shareVia(image:image)
            }
        }
        
        private func shareVia(image:UIImage){
            let saveImagePath = NSTemporaryDirectory() + "/instagramshare.igo"
            let imageData = UIImageJPEGRepresentation(image,0.7)!
            (imageData as NSData).write(toFile: saveImagePath, atomically: true)
            assert(FileManager.default.fileExists(atPath: saveImagePath))
            
            let imageURL = URL(fileURLWithPath: saveImagePath)
            
            let docController  = UIDocumentInteractionController(url: imageURL)
            
            docController.uti = "com.instagram.exclusivegram"
            
            docController.url = imageURL
            docController.delegate = self
            
            self.docController = docController
        }
        
        private func shareVia(photoID:String){
            
            let u = "instagram://library?LocalIdentifier=" + photoID
            let url = URL(string: u)!
                UIApplication.shared.openURL(url)//(url, options: [:], completionHandler: nil)
            
            return
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
    }
    
}

extension Share.Instagram: Retainer, UIDocumentInteractionControllerDelegate {
    typealias Retainee = Share.Instagram
}
