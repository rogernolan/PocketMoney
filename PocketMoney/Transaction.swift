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
    @NSManaged var name : NSString
    @NSManaged var account: Account?
    
    class func parseClassName() -> String {
        return "Transaction"
    }
    
    override init() {

        super.init()

    }
    
    convenience init(account anAccount:Account, name aName:String, amount anAmount:Double) {
        
        self.init()
        
        name = aName
        account = anAccount
        amount = anAmount
        

    }
}
