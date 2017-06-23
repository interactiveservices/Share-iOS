//
//  File.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 05/06/2017.
//
//

import UIKit
import MessageUI

extension Share {
    
    open class Email:NSObject,Sharer {
        
        public typealias Item = Letter
        public typealias Sender = Email
        public typealias ShareError = EmailError
        
        public var presentingViewController:UIViewController?
        
        public init(presentingViewController:UIViewController? = nil){
            self.presentingViewController = presentingViewController
        }
        
        open func shareBy(item: Item, completion: ((Completion)->Void)? = nil) {
            self.completion = completion
            self.shareItem  = item
            
            guard MFMailComposeViewController.canSendMail() else {
                
                self.callCompletionWith( .error(.canNotSendMail))
                return
            }
            
            let mvc = buildMailController(with: item)
            mvc.mailComposeDelegate = self
            retainSelf()
            
            UIViewController.share_present(viewController: mvc,
                                           from: presentingViewController)
        }
        
        fileprivate var completion:((Completion)->Void)?
        fileprivate var shareItem:Letter!
        
        public struct Letter {
            var subject:String
            var recipients:[String]
            var ccRecipients:[String]? = nil
            var bccRecipients:[String]? = nil
            var body:String
            var bodyIsHTML = false
            var attachments:[Attachment]
            
            public init(subject:String, recipients:[String],ccRecipients:[String]? = nil, bccRecipients:[String]? = nil, body:String, bodyIsHTML:Bool = false, attachments:[Attachment] = [])
            {
                self.subject = subject
                self.recipients = recipients
                self.ccRecipients = ccRecipients
                self.bccRecipients = bccRecipients
                self.body = body
                self.bodyIsHTML = bodyIsHTML
                self.attachments = attachments
            }
        }
        
        public enum EmailError:Error {
            case canNotSendMail
            case canceled
            case systemError(Error)
        }
        
        public struct  Attachment{
            public var data:Data
            public var mimeType:String
            public var fileName:String
            
            public init(data: Data, mimeType: String, fileName: String) {
                self.data = data
                self.mimeType = mimeType
                self.fileName = fileName
            }
        }
        
        var objectToRetain:Email?
        
        fileprivate func callCompletionWith(_ result:ShareResult<ShareError>){
            self.completion?((sharer: self,
                              item: self.shareItem,
                              result: result))
        }
    }
}

extension Share.Email: Retainer {
    
    typealias Retainee = Share.Email
    fileprivate func buildMailController(with letter:Letter)->MFMailComposeViewController{
        
        let mvc = MFMailComposeViewController()
        
        mvc.setSubject(letter.subject)
        mvc.setToRecipients(letter.recipients)
        mvc.setCcRecipients(letter.ccRecipients)
        mvc.setBccRecipients(letter.bccRecipients)
        mvc.setMessageBody(letter.body, isHTML: letter.bodyIsHTML)
        letter.attachments.forEach{
            mvc.addAttachmentData($0.data, mimeType: $0.mimeType, fileName: $0.fileName)
        }
        
        return mvc
    }
}

extension Share.Email: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
       
        switch result
        {
            
        case .cancelled:
            self.callCompletionWith( .error(.canceled))
        case .failed:
            if let error = error {
                print("error sending mail:\(error)")
                self.callCompletionWith( .error(.systemError(error)))
            }
        case .sent:
            self.callCompletionWith(.success)
        case .saved:
            self.callCompletionWith(.success)
        }
        
        controller.mailComposeDelegate = nil
        controller.dismiss(animated: true, completion: nil)
        releaseSelf()
    }
}
