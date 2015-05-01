//
//  Account.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

// import Parse

enum Source {
    case server, local
}

class Account : PFObject, PFSubclassing {
    @NSManaged var balance : Double
    @NSManaged var name : String?
    @NSManaged var owner : PFUser
    
    class func parseClassName() -> String {
        return "Account"
    }
    
    convenience init(name aName:String,  balance aBalance:Double, user: PFUser?) {
        self.init()
        name = aName
        balance = aBalance
        // We crash if you try to make an account without being logged in.
        owner = user != nil ?  user! : PFUser.currentUser()!
    }
    
    // MARK: - debug
    
    class func loadFrom(source:Source, callback:(accounts:[Account]?, error:NSError!) -> Void) {
        if let user = PFUser.currentUser() {
            let query = PFQuery(className:Account.parseClassName())
            query.whereKey("owner", equalTo: user)
            query.limit = 100
            if source == .local {
                query.fromLocalDatastore()
            }
            query.findObjectsInBackgroundWithBlock() { (objects: [AnyObject]?, error:NSError?) -> Void in
                //
                if let e = error {
                    println("error fetching Accounts data from parse: \(e)")
                    return callback(accounts: nil, error: error)
                    
                }
                else {
                    callback(accounts: objects as? [Account], error: error)
                }
            }

        }
        else {
            callback(accounts: nil, error: NSError(domain: "PocketMoney", code: 0, userInfo: [NSLocalizedDescriptionKey : "Not logged in"]))

        }
    }

    func addTransaction(name:String, amount:Double){
        let transaction = Transaction(account: self, name: name, amount: amount)
        transaction.pin()
        
        balance -= amount
        
        self.saveEventually(nil)
        transaction.saveEventually(nil)
    }
}

extension Account : DebugPrintable, Printable {
    
    override var debugDescription : String {
        return self.description
    }
    
    override var description  : String {
        return super.description + "Account: \(name) : £\(balance)"
    }
    
}
