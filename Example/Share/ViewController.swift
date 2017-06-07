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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        
    }
    
    @IBAction func share(){
        let shareDialog = UIAlertController(title: "Share", message: "select share service", preferredStyle: .actionSheet)
        
        func actionWith(title:String,handler:@escaping (UIAlertAction)->Void)->UIAlertAction {
            return UIAlertAction(title: title, style: .default, handler: handler)
        }
        
        shareDialog.addAction(actionWith(title: "e-mail"){ _ in
            self.shareByMail()}
        )
        
        shareDialog.addAction(actionWith(title: "iMessage") { _ in
            self.shareByMessage()
        })
        
        
        
        present(shareDialog, animated: true, completion: nil)
    }
    
    //MARK: - Share
    
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
    
}

