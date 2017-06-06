//
//  Message.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 06/06/2017.
//
//

import MessageUI
import UIKit

extension Share {
    open class iMessage:NSObject,Sharer {
        
        public typealias Item = (message:Message, vc:UIViewController)
        
        public static func shareBy(item: (message: Share.iMessage.Message, vc: UIViewController)) {
            
        }
        
        public struct  Message {
            var recipients:[String]
            var subject:String?
            var body:String?
            var attachments:[Attachement]
            
            public init(recipients: [String], subject: String? = nil, body: String? = nil, attachments: [Attachement] = []) {
                self.recipients = recipients
                self.subject = subject
                self.body = body
                self.attachments = attachments
            }
            
        }
        
        public enum Attachement {
            case data(data:Data,typeIdentifier:String,fileName:String)
            case url(url:URL,alternateFileName:String?)
        }
        
        
        typealias Retainee = iMessage
        var objectToRetain:iMessage?
    }
    
}

extension Share.iMessage: Retainer {
    
    fileprivate func shareBy(item:Item){
        
        let mvc = buildMessage(with: item.message)
        mvc.messageComposeDelegate = self
        retainSelf()
        
        item.vc.present(mvc, animated: true, completion: nil)
    }
    
    private func buildMessage(with message:Message)->MFMessageComposeViewController{
        
        let mvc = MFMessageComposeViewController()
        
        mvc.recipients = message.recipients
        mvc.subject = message.subject
        mvc.body = message.body

        message.attachments.forEach{ attachment in

            switch attachment
            {
            case .data(data: let data, typeIdentifier: let id, fileName: let name):
                mvc.addAttachmentData(data, typeIdentifier: id, filename: name)
                
            case .url(url: let url, alternateFileName: let fileName):
                mvc.addAttachmentURL(url, withAlternateFilename: fileName)
            }
        }
        
        return mvc
    }
}

extension Share.iMessage : MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result {
        case .cancelled, .failed, .sent:
            controller.messageComposeDelegate = nil
            controller.dismiss(animated: true, completion: nil)
        }
        releaseSelf()
    }
}
