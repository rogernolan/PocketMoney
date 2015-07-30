//
//  CreateAccount.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit
// import Parse

class EditAccountViewController : UITableViewController {

    @IBOutlet weak var balance: UITextField!
    @IBOutlet weak var accountName: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var balanceLabel: UILabel!
    
    var account : Account?
    
    
    var currencyFormatter: NSNumberFormatter {
        struct Static {
            static let instance : NSNumberFormatter = {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .CurrencyStyle
                return formatter
                }()
        }
        
        return Static.instance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupForAccount()
    
    }
    
    func setupForAccount(){
        if let a = account {
            balanceLabel.text = "Balance"
            accountName.text = a.name
            balance.text = currencyFormatter.stringFromNumber(a.balance)
        }
        else {
            balanceLabel.text = "Opening balance"

        }
    }
    
    // MARK: UI Events
    
    @IBAction func done(sender: AnyObject) {
        if let name = accountName.text, let balanceAmount = balance.text?.doubleValue
        {

            if let a = account {
                // editing
                
                if balanceAmount <= 0 {
                    // Best to confirm negative or zero balance.
                    var messageString = "Are you sure you want to make this account overdrawn?"
                    if balanceAmount == 0.0 {
                        messageString = "Are you sure you want to clear this account balance?"
                    }
                    let alert = UIAlertController(title: "Save?", message: messageString, preferredStyle: .Alert)
                    let yes = UIAlertAction(title: "Yes", style: .Default ){ (_:UIAlertAction) -> Void in
                        a.name = name
                        a.balance = balanceAmount
                        a.saveEventually()
                        self.performSegueWithIdentifier("haveEditedAccount", sender: self)
                    }
                    let no = UIAlertAction(title: "No", style: .Cancel) { (_:UIAlertAction) -> Void in }
                    alert.addAction(yes)
                    alert.addAction(no)
                    self.presentViewController(alert, animated: true){}
                }
                else {
                    // Just save straight away
                    a.name = name
                    a.balance = balanceAmount
                    a.saveEventually()
                    self.performSegueWithIdentifier("haveEditedAccount", sender: self)
                }

            }
            else {
                let account = Account(name: name, balance: balanceAmount, user:PMUser.currentUser())
                account.pinInBackgroundWithBlock { (status: Bool, error:NSError?) -> Void in
                    account.saveEventually() { (saved: Bool, error:NSError?) -> Void in
                        // code
                    }
                }
                self.performSegueWithIdentifier("haveCreatedAccount", sender: self)
            }
        }
    }
}


extension EditAccountViewController : UITextFieldDelegate {
    
    // MARK: UITExtViewDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == accountName {
            balance.becomeFirstResponder()
        }
        return true
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
    var proposedAmountString = balance.text ?? ""
    var proposedName = accountName.text ?? ""

    if textField == balance {
        let existingString = balance.text ?? ""
        let swiftRange = existingString.swiftRangeFrom(range)
        proposedAmountString = existingString.stringByReplacingCharactersInRange(swiftRange, withString: string)
        let components = proposedAmountString.componentsSeparatedByString(".")
        if components.count > 2 {
            return false
        }
        if components.count == 2 {
            let pennies = components[1]
            if pennies.characters.count > 2 {
                return false
            }
        }
    }
    else if textField == accountName {
        let existingString = accountName.text ?? ""
        let swiftRange = existingString.swiftRangeFrom(range)
        proposedName = existingString.stringByReplacingCharactersInRange(swiftRange, withString: string)
        if proposedName.characters.count > 0 && (proposedAmountString.doubleValue != 0.0 && account != nil) {
            saveButton.enabled = true
        }
        else {
            saveButton.enabled = false
        }
            
    }
        

        return true
    }
    
    func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField == accountName {
            let string = textField.text ?? ""
            if string.characters.count > 1 {
                return true
            }
            return false
            
        }
        return true
    }
}