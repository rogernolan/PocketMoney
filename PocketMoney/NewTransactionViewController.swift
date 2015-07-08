//
//  NewTransactionViewController.swift
//  PocketMoney
//
//  Created by roger nolan on 14/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit

public class NewTransactionViewController: UITableViewController {

    var account : Account?
    
    @IBOutlet weak var amountEdit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var endOfMonthSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var lastTransactionName : String?
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        amountEdit.font = amountEdit.font.copyWithTabularNumbers()
    }
    
    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        saveButton.enabled = false
        nameEdit.becomeFirstResponder()
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveTapped(sender: AnyObject) {
        if let transactionTitle = self.nameEdit.text, ac = account {
            if endOfMonthSwitch.on == true {
                ac.endMonth(transactionTitle, amount: self.amountEdit.text.doubleValue, callback: { (error) -> Void in
                    // code
                })
            }
            else {
                ac.addTransaction(transactionTitle , amount: self.amountEdit.text.doubleValue)
            }
            self.navigationController?.popViewControllerAnimated(true)
        }

    }
    
    @IBAction func endOfMonthSwitched(sender: AnyObject) {
        if endOfMonthSwitch.on == true {
            lastTransactionName = nameEdit.text
            nameEdit.text = "End of Month"
            }
        else {
            if let s = lastTransactionName {
                nameEdit.text = s
            }
            else {
                nameEdit.text = ""
            }
        }
    }

}
extension NewTransactionViewController : UITextFieldDelegate {
    
    // MARK: UITExtViewDelegate

    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == nameEdit {
            amountEdit.becomeFirstResponder()
        }
        return true
    }
    
    public func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

        var proposedAmountString = amountEdit.text
        var proposedName = nameEdit.text
        
        
        if textField == amountEdit {
            let existingString = amountEdit.text as NSString
            proposedAmountString = existingString.stringByReplacingCharactersInRange(range, withString: string)
            let components = proposedAmountString.componentsSeparatedByString(".")
            if count(components) > 2 {
                return false
            }
            if count(components) == 2 {
                let pennies = components[1]
                if count(pennies) > 2 {
                    return false
                }
            }
        }
        else if textField == nameEdit {
            let existingString = nameEdit.text as NSString
            proposedName = existingString.stringByReplacingCharactersInRange(range, withString: string)
        }
        
        if count(proposedName) > 0 && proposedAmountString.doubleValue != 0.0 {
            saveButton.enabled = true
        }
        else {
            saveButton.enabled = false
        }
        
        return true
    }
    
    public func textFieldShouldEndEditing(textField: UITextField) -> Bool {
        if textField == nameEdit {
            let string = nameEdit.text
            if count(string) > 1 {
                return true
            }
            return false
            
        }
        return true
    }
}
