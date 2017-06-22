//
//  UIViewController+Utils.swift
//  Share
//
//  Created by Nikolay Shubenkov on 20/06/2017.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func show(title:String? = nil, message:String? = nil) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
}

extension URL {
    
    static let awesomeLink = URL(string:"http://be-interactive.ru/mobile")!
}

extension String {
    
    static let beInteractiveHashTag = "#beinteractive"
    
}
