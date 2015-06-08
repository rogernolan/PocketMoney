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
    
    var lastTransactionName : String?
    

    override public func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        nameEdit.becomeFirstResponder()
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override public func viewDidDisappear(animated: Bool) {
        // Check that we are being dismissed from the top of the stack. Means back has been pressed and we should create a
        // new transaction
        if let description = self.nameEdit.text, ac = account, vcs = self.navigationController?.viewControllers as? [NSObject] {
            if contains(vcs, self) {
                if endOfMonthSwitch.on == true {
                    ac.endMonth(description, amount: self.amountEdit.text.doubleValue, callback: { (error) -> Void in
                        // code
                    })

                }
                else {
                    ac.addTransaction(description , amount: self.amountEdit.text.doubleValue)
                }
            }
        }
        super.viewDidDisappear(animated)
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

        if textField == amountEdit {
            let existingString = amountEdit.text as NSString
            let proposedString = existingString.stringByReplacingCharactersInRange(range, withString: string)
            let components = proposedString.componentsSeparatedByString(".")
            if count(components) > 2 {
                return false
            }
            let pennies = components[1]
            if count(pennies) > 2 {
                return false
            }

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
