# Share

[![CI Status](http://img.shields.io/travis/nikolay.shubenkov@gmail.com/Share.svg?style=flat)](https://travis-ci.org/nikolay.shubenkov@gmail.com/Share)
[![Version](https://img.shields.io/cocoapods/v/Share.svg?style=flat)](http://cocoapods.org/pods/Share)
[![License](https://img.shields.io/cocoapods/l/Share.svg?style=flat)](http://cocoapods.org/pods/Share)
[![Platform](https://img.shields.io/cocoapods/p/Share.svg?style=flat)](http://cocoapods.org/pods/Share)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

```swift

import Share

//Share by message

//For example add this in your view controller's button handling code. 

let message = Share.IMessage.Message(recipients: ["somebodyPhonenumber"],body:"Hello, man!")
Share.IMessage().shareBy(item: message)

//more advanced usage 
 
 let attachment = Share.IMessage.Attachement.data(data: UIImagePNGRepresentation(UIImage(named:"sendimage"))!,
                                                         typeIdentifier: "image/png",
                                                         fileName: "nice.png")
        let message = Share.IMessage.Message(recipients: ["somebodyPhonenumber"],
                                             subject: "No subject :)",
                                             body: "Hello. How are you?",
                                             attachments: [attachment])
        
        Share.IMessage().shareBy(item: message) {  sharer,item,result in
            print("finished with:\nsharer\(sharer)\nitem:\(item)\nresult:\(result)")
        }
//Mail

let letter = Share.Email.Letter(subject: "Hello test letter",
                                        recipients: ["1@mail.ru","admin@mail.ru"],
                                        body: "some body for Email",
                                        bodyIsHTML: false)

Share.Email().shareBy(item:latter)

//General Activity ViewController

let shareElements:[Any] = ["stupid text",
                           URL(string:"https://github.com/interactiveservices/")!,
                           #imageLiteral(resourceName: "sendimage"), 
                           Date()]
Share.Activity().shareBy(item:shareElements)
```

## Requirements

## Installation

Share is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "Share"
```

## Author

nikolay.shubenkov@gmail.com, n.shubenkov@be-interactive.ru

## License

Share is available under the MIT license. See the LICENSE file for more info.
