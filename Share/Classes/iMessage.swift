//
//  Message.swift
//  Pods
//
//  Created by Nikolay Shubenkov on 06/06/2017.
//
//

import MessageUI
import UIKit

public protocol iMessageDelegate:class {
    
}

extension Share {
    open class IMessage:NSObject,Sharer {
        
        public typealias Item = (message:Message, vc:UIViewController)
        public typealias Sender = IMessage
        public typealias ShareError = MessageError
        
        public func shareBy(item:Item, completion:((Completion)->Void)?){
            let mvc = buildMessage(with: item.message)
            
            self.shareItem = item
            mvc.messageComposeDelegate = self
            retainSelf()
            
            item.vc.present(mvc, animated: true, completion: nil)
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
        
        public enum MessageError:Error {
            case canNotSendMessages
            case canceled
            case failed
        }
        
        public enum Attachement {
            case data(data:Data,typeIdentifier:String,fileName:String)
            case url(url:URL,alternateFileName:String?)
        }
        
        var objectToRetain:IMessage?
        
        fileprivate var completion:((Completion)->Void)?
        fileprivate var shareItem:(message:Message, vc:UIViewController)!
        
        fileprivate func callCompletion(_ result:ShareResult<MessageError>){
            self.completion?((sharer:self,
                              item:self.shareItem,
                              result:result))
        }
    }
}

extension Share.IMessage: Retainer {
    
    typealias Retainee = Share.IMessage
    fileprivate func buildMessage(with message:Message)->MFMessageComposeViewController{
        
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

extension Share.IMessage : MFMessageComposeViewControllerDelegate {
    public func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult)
    {
        switch result
        {
        case .cancelled:
            self.callCompletion(ShareResult<MessageError>.cancel)

        case .failed:
            self.callCompletion(ShareResult<MessageError>.error(.failed))

        case .sent:
            self.callCompletion(.success)
        }
        controller.messageComposeDelegate = nil
        controller.dismiss(animated: true, completion: nil)
        releaseSelf()
    }
}
