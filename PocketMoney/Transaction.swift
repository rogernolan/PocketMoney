//
//  Transaction.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import Parse

class Transaction: PFObject, PFSubclassing {
    @NSManaged var amount: Double
    @NSManaged var name : String?
    @NSManaged var account: Account
    
    class func parseClassName() -> String {
        return "Transaction"
    }
    
    init(account anAccount:Account, name aName:String, amount anAmount:Double) {
        
        super.init()
        
        name = aName
        account = anAccount
        amount = anAmount
        

    }
}
