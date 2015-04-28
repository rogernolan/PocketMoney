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
    
    class func parseClassName() -> String {
        return "Account"
    }
    
    convenience init(name aName:String, balance aBalance:Double) {
        self.init()
        name = aName
        balance = aBalance
        self.pin()
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
        transaction.pin()
        
        balance -= amount

        self.saveEventually(nil)
        transaction.saveEventually(nil)
    }

}
