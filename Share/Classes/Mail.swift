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
    
    open class Mail:NSObject,Sharer {
        
        public typealias Item = (letter:Letter, vc:UIViewController)
        
        public static func shareBy(item: (letter: Share.Mail.Letter, vc: UIViewController)) {
            Mail().shareBy(item: item)
        }

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
        
        public struct  Attachment{
            var data:Data
            var mimeType:String
            var fileName:String
        }
        
        typealias Retainee = Mail
        var objectToRetain:Mail?        
    }
}

extension Share.Mail: Retainer {
    
    fileprivate func shareBy(item: Item) {
        
        
        let mvc = buildMailController(with: item.letter)
        mvc.mailComposeDelegate = self
        retainSelf()
        
        item.vc.present(mvc, animated: true, completion: nil)
    }
    
    private func buildMailController(with letter:Letter)->MFMailComposeViewController{
        
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

extension Share.Mail: MFMailComposeViewControllerDelegate {
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled, .failed, .sent, .sent:
            if let error = error {
                print("error sending mail:\(error)")
            }
            controller.mailComposeDelegate = nil
            controller.dismiss(animated: true, completion: nil)
        default:
            break
        }
        releaseSelf()
    }
}
