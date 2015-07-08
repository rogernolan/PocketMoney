//
//  UIAlertView+SingleButtonAlert.swift
//  PocketMoney
//
//  Created by Roger Nolan on 06/07/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import Foundation

extension UIAlertView {
    class func singleButtonAlert(title:String, message:String, button:String, completion:(()->Void)? = nil) -> UIAlertController! {
    
        let alert = UIAlertController(title:title, message: message, preferredStyle: .Alert)

        let button = UIAlertAction(title:title, style: .Default) {(_) -> Void in
            if let c = completion {
                c();
            }
        }
        alert.addAction(button)
        return alert;
    }
}
