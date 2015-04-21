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
    @NSManaged var name : String
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
    
    func transactionsForAccount(anAccount:Account, callback: (objects: [Transaction]?, error: NSError?) -> Void) {
        let pred = NSPredicate(format: "Account = %@", anAccount)
        if let query = Transaction.queryWithPredicate(pred) {
            query.fromLocalDatastore()
            query.findObjectsInBackgroundWithBlock(){ (objects: [AnyObject]?, error: NSError?) -> Void in
                if error == nil  {
                    callback(objects: nil, error: error)
                }
                
                var fakeError :NSError?
                let transactions = objects as? [Transaction]
                if  transactions == nil  {
                    fakeError = NSError(domain: "SelfServe", code: 500, userInfo: [NSLocalizedDescriptionKey: "empty array received from Parse"])
                }

                callback(objects: transactions, error: fakeError)
            }
        }
        
    }
}
