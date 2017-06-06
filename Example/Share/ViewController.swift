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
        let attachment = Share.Email.Attachment(data: UIImagePNGRepresentation(#imageLiteral(resourceName: "sendimage"))!,
                                                mimeType: "image/png",
                                                fileName: "smile.png")

        let letter = Share.Email.Letter(subject: "Hello test letter",
                                         recipients: ["1@mail.ru","admin@mail.ru"],
                                         ccRecipients: ["ccrec@mail.ru"],
                                         bccRecipients: ["bccRec@mail.ru"],
                                         body: "some body for Email",
                                         bodyIsHTML: false,
                                         attachments: [attachment])
        
        Share.Email().shareBy(item: (letter,self)){ sharer,item,result in
            
        }
    }
    
}

