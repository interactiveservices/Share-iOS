//
//  ViewController.swift
//  Share
//
//  Created by nikolay.shubenkov@gmail.com on 06/05/2017.
//  Copyright (c) 2017 nikolay.shubenkov@gmail.com. All rights reserved.
//

import UIKit
import Share

class ViewController: UIViewController {

    @IBAction func share(){
        let shareDialog = UIAlertController(title: "Share", message: "Select sharing service", preferredStyle: .actionSheet)
        
        
        shareDialog.addAction(actionWith(title: "e-mail"){ _ in
            self.shareByMail()}
        )
        
        shareDialog.addAction(actionWith(title: "iMessage") { _ in
            self.shareByMessage()
        })
        
        shareDialog.addAction(actionWith(title: "ActivityViewController"){ _ in
            self.shareByActivity()
        })
        
        shareDialog.addAction(actionWith(title: "Instagram") { _ in
            self.shareByInstagram()
        })
        
        shareDialog.addAction(actionWith(title: "Cancel", style: .cancel))
        
        present(shareDialog, animated: true, completion: nil)
    }

    func actionWith(title:String, style:UIAlertActionStyle = UIAlertActionStyle.default, handler: ((UIAlertAction)->Void)? = nil)->UIAlertAction {
        return UIAlertAction(title: title, style: style, handler: handler)
    }
    
    //MARK: - Share
    
    func shareByInstagram(){
        
        let asset = Share.Instagram.Asset.image(#imageLiteral(resourceName: "sendimage"))
        
        Share.Instagram().shareBy(item: asset) {  sharer,item,result in
            print("finished with:\nsharer\(sharer)\nitem:\(item)\nresult:\(result)")
        }
    }
    
    func shareByMessage(){
        let attachment = Share.IMessage.Attachement.data(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "sendimage"))!,
                                                         typeIdentifier: "image/png",
                                                         fileName: "LuckyMan.png")
        let message = Share.IMessage.Message(recipients: ["7655656"],
                                             subject: "No subject",
                                             body: "Hello. How are you?",
                                             attachments: [attachment])
        
        Share.IMessage().shareBy(item: (message,self)) {  sharer,item,result in
            print("finished with:\nsharer\(sharer)\nitem:\(item)\nresult:\(result)")
        }
    }
    
    func shareByMail(){
        let attachment = Share.Email.Attachment(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "sendimage"))!,
                                                mimeType: "image/png",
                                                fileName: "LuckyMan")
        
        let letter = Share.Email.Letter(subject: "Hello test letter",
                                        recipients: ["1@mail.ru","admin@mail.ru"],
                                        ccRecipients: ["ccrec@mail.ru"],
                                        bccRecipients: ["bccRec@mail.ru"],
                                        body: "some body for Email",
                                        bodyIsHTML: false,
                                        attachments: [attachment])
        
        Share.Email().shareBy(item: (letter,self)){ sharer,item,result in
            
            print("finished with:\nsharer\(sharer)\nitem:\(item)\nresult:\(result)")
            
        }
    }
    
    func shareByActivity(){
        let shareElements:[Any] = ["stupid text",URL(string:"http://www.yandex.ru")!,#imageLiteral(resourceName: "sendimage"), Date()]
        Share.Activity().shareBy(item:(shareElements,
                                       self)) { sharer,item,result in
            print("finished with:\nsharer\(sharer)\nitem:\(item)\nresult:\(result)")}
    }
    
}

