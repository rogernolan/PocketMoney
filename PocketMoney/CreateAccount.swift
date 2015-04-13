//
//  CreateAccount.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit
import Parse

class CreateAccount: UITableViewController {

    @IBOutlet weak var openingBalance: UITextField!
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBAction func done(sender: AnyObject) {
        
        let account = Account(name: accountName.text!, balance: Double(openingBalance.text.floatValue))
        account.pinInBackgroundWithBlock { (status: Bool, error:NSError?) -> Void in
            account.saveEventually() { (saved: Bool, error:NSError?) -> Void in
                // code
            }
            
            self.dismissViewControllerAnimated(true , completion: { () -> Void in
                //
            })
        }


    }
}
