//
//  Account.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import Parse

class Account : PFObject, PFSubclassing {
    @NSManaged var balance : Double
    @NSManaged var name : String?
    @NSManaged var transactions: Array<Transaction>?
    
    class func parseClassName() -> String {
        return "Account"
    }
    
    convenience init(name aName:String, balance aBalance:Double) {
        self.init()
        name = aName
        balance = aBalance
    }
    
    // MARK: - debug
    
    override var debugDescription : String {
        return self.description
    }
    
    override var description  : String {
        return super.description + "Account: \(name) : £\(balance)"
    }
    
    func addTransaction(name:String, amount:Double){
        let transaction = Transaction(account: self, name: name, amount: amount)
        if var tr = transactions {
            tr.append(transaction)
        }
        else {
            transactions = [transaction]
        }
        balance -= amount
        
        self.saveInBackgroundWithBlock { (saved: Bool, error: NSError?) -> Void in
            if error == nil {
                self.saveEventually(nil)
            }
        }
    }
}
