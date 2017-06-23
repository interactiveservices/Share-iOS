//
//  ViewController.swift
//  Share
//
//  Created by nikolay.shubenkov@gmail.com on 06/05/2017.
//  Copyright (c) 2017 nikolay.shubenkov@gmail.com. All rights reserved.
//

import UIKit
import Share
import FacebookShare
import FBSDKShareKit

class ViewController: UIViewController {
    
    @IBAction func share(_ button:UIButton){
        
        let shareDialog = UIAlertController(title: "Share", message: "Select sharing service", preferredStyle: .actionSheet)
        
        shareDialog.addAction(actionWith(title: "e-mail"){ _ in
            self.shareByMail()
        })
        
        shareDialog.addAction(actionWith(title: "iMessage") { _ in
            self.shareByMessage()
        })
        
        shareDialog.addAction(actionWith(title: "ActivityViewController"){ _ in
            self.shareByActivity()
        })
        
        shareDialog.addAction(actionWith(title: "Instagram") { _ in
            self.shareByInstagram()
        })
        
        shareDialog.addAction(actionWith(title: "Vk") { _ in
            self.shareByVk()
        })
        
        shareDialog.addAction(actionWith(title: "Vk user info") { _ in
            self.retrieveVkUserInfo()
        })
        
        shareDialog.addAction(actionWith(title: "Facebook") { _ in
            self.shareByFacebook()
            
        })
        
        shareDialog.addAction(actionWith(title: "Facebook user info") { _ in
            self.retrieveFbUserInfo()
        })
        
        shareDialog.addAction(actionWith(title: "Facebook friends") { _ in
            self.retrieveFbFriends()
        })
        
        shareDialog.addAction(actionWith(title: "Facebook feed") { _ in
            self.retrieveFbFeed()
        })
        
        shareDialog.addAction(actionWith(title: "Cancel", style: .cancel))
        
        shareDialog.popoverPresentationController?.sourceView = button
        shareDialog.popoverPresentationController?.sourceRect = button.bounds
        shareDialog.modalPresentationStyle = .popover
        
        present(shareDialog, animated: true, completion: nil)
    }
    
    func actionWith(title:String, style:UIAlertActionStyle = UIAlertActionStyle.default, handler: ((UIAlertAction)->Void)? = nil)->UIAlertAction {
        return UIAlertAction(title: title, style: style, handler: handler)
    }
    
    //MARK: - Share
    
    func shareByFacebook(){
        
        func share() {
            
            let photo =  Photo(image: #imageLiteral(resourceName: "sendimage"),
                                userGenerated: true)

            var content = PhotoShareContent(photos:[photo])
            content.hashtag = Hashtag(String.awesomeTag)
            
            _ = try? ShareDialog<PhotoShareContent>
                     .show(from: self,
                           content: content){ result in
                            print("share result is:\n\(result)")
                            
            }
        }
        
        if Share.FacebookAuthoriser.isAuthorised {
            share()
            return
        }
        
        AppDelegate.delegate.facebookAuthorizer.authWith(success: { _ in
            
            share()
            
        }) { error in
            self.show(title: "Ошибка", message: "\(error)")
        }
    }
    
    func retrieveFbFeed(){
        let sharer = Share.Facebook(authoriser: AppDelegate.delegate.facebookAuthorizer)
        
        let request = Share.Facebook.Request(path: "/me/feed",
                                             paging: (pageLimit:Share.Facebook.PagesCount.limited(10),
                                                      pagingKey: Optional<String>.none))
        sharer.make(request: request) { result in
            print("feed\n:\(result)")
        }
    }
    
    func retrieveFbFriends() {
        
        let sharer = Share.Facebook(authoriser: AppDelegate.delegate.facebookAuthorizer)
        
        let request = Share.Facebook.Request(path: "/me",
                                             parameters:["fields" : "friends{name,id,picture{url}},picture.width(300).height(300){url},name" ],
                                             paging: (pageLimit:Share.Facebook.PagesCount.unlimited,
                                                      pagingKey:Optional<String>.none))
        
        sharer.make(request: request) { data in
            print("friends\n:\(data)")
        }
        
    }
    
    func retrieveFbUserInfo(){
        
        let sharer = Share.Facebook(authoriser: (UIApplication.shared.delegate as? AppDelegate)?.facebookAuthorizer)
        
        sharer.getUserInfo { result in
            
            switch result {

            case .success(let data): self.show(title: "Успех", message: data.description)
            case .error(let error): self.show(title: "Ошибка", message: "\(error)")
                
            }
            print("Recieved FB User Info with:\n\(result)")
            
        }
        
    }
    
    func retrieveVkUserInfo(){
        
        let sharer = Share.Vk(authoriser: (UIApplication.shared.delegate as? AppDelegate)?.vkAuthorizer,
                              presentingController: self)
        
        sharer.getUserInfoWith { result in
            
            switch result {

            case .success(let data): self.show(title: "Успех", message: data.description)
                
            case .error(let error): self.show(title:"Ошибка", message: "\(error)")
                
            }
            print("Recieved VK User Info with:\n\(result)")
        }
    }
    
    func shareByVk(){
        
        let sharer = Share.Vk(authoriser: (UIApplication.shared.delegate as? AppDelegate)?.vkAuthorizer,
                              presentingController: self)
        
        let vkContent = Share.Vk.Item(text: "How are you?",
                                      images: [#imageLiteral(resourceName: "sendimage")],//)//,
                                      link: ("Be-Interactive",
                                            URL.awesomeLink))
        
        sharer.shareBy(item: vkContent){ sharer, item, result in
            
            print("finished with:\nsharer\(sharer)\nitem:\(item)\nresult:\(result)")
            
        }
    }
    
    func shareByInstagram(){
        
        let asset = Share.Instagram.Asset.image(#imageLiteral(resourceName: "sendimage"), view: self.view)
        
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
        let shareElements:[Any] = ["stupid text",URL(string:"http://be-interactive.ru/mobile/")!,#imageLiteral(resourceName: "sendimage"), Date()]
        Share.Activity().shareBy(item:(shareElements,
                                       self)) { sharer,item,result in
                                        print("finished with:\nsharer\(sharer)\nitem:\(item)\nresult:\(result)")}
    }
    
}
// Коля пидОр
