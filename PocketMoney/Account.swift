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

class Account : PFObject, PFSubclassing{
    @NSManaged var balance : Double
    @NSManaged var name : String?
    @NSManaged var owner : PFUser
    @NSManaged var lastMonthEnd : NSDate
    
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
    
    /**
    Load Account records for current user from the specified source.
    
    :param: source   specify whether to fetch locally or remotely.
    :param: callback called when data is available or an error occured.
    */
    
    class func loadFrom(source:Source, callback:(accounts:[Account]?, error:NSError!) -> Void) -> BFTask! {
        if let user = PFUser.currentUser() {
            let query = PMUser.query()
            query?.includeKey("accounts")
            if source == .local {
                query?.fromLocalDatastore()
            }
            return query?.getObjectInBackgroundWithId(user.objectId!).continueWithBlock{ (task:BFTask!) -> BFTask! in
                if let e = task.error {
                    println("error fetching Accounts data from parse: \(e)")
                    callback(accounts: nil, error: e)
                    return task
                }
                else {
                    if let user = task.result as? PMUser, accounts = user.accounts as? [Account] {
                        callback(accounts: accounts , error: nil)
                        return PFObject.pinAllInBackground(accounts)
                    }
                    else {
                        callback(accounts: nil , error: NSError(domain: "PocketMoney", code: 500, userInfo: nil))
                        return task
                    }
                }
            }
        }
        else {
            let error = NSError(domain: "PocketMoney", code: 500, userInfo: [NSLocalizedDescriptionKey : "Not logged in"])
            callback(accounts: nil, error: error)
            return BFTask(error: error)
        }
    }

    /**
    Add a transaction to an account. Will auto decrement the balance
    
    :param: name         Name of the tranasaction
    :param: amount       the amount of the transaction
    */
    func addTransaction(name:String, amount:Double){
        let transaction = Transaction(account: self, name: name, amount: amount)
        transaction.pinInBackgroundWithBlock({ (pinned: Bool, error: NSError?) -> Void in
            transaction.saveEventually(nil)
        })
        
        balance -= amount
        
        self.saveEventually(nil)
    }
    
    /**
    Insert an end of month transaction into the account, incrememnts balance and archives all of the current transactions.
    
    :param: note        description for end of month
    :param: amount      amount to increase balance by
    :param: callback    called when all transactions have been archived.
    */
    
   func endMonth(note:String, amount:Double, callback:((error:NSError!) -> Void)? = nil ) -> BFTask!{
    
        var transactions = Array<Transaction>()
    
        let bolt = BFTask()
        bolt.continueWithBlock { (task: BFTask!) -> AnyObject! in
            println("This does compile")
            return nil
        }
    
        var eom : Transaction? = nil
        // Get the transactions for this month.
        // We get them before creating the EOM transaction so we don't
        // archive it immediately after creation.
       return Transaction.transactionsForAccount(account: self).continueWithSuccessBlock{ (task: BFTask!) -> BFTask in
            if let array = task.result as? [Transaction] {
                transactions = array
            }
            
            // Now we have the other trasactions to archive, create an end of month transaction to start
            // the new month.
            eom = Transaction(account: self, name: note, amount: -amount)
            eom!.endOfMonth = true
            return eom!.pinInBackground()
        
        }.continueWithSuccessBlock{ (task: BFTask!) -> BFTask in
            if let pinnedObject = eom {
                pinnedObject.saveEventually()
            }
            else {
                return BFTask(error: NSError(domain: "PocketMoney", code: 500, userInfo: nil))
            }
            // Now we are sure the transaction is saved, add the balance.
            self.balance += amount
            self.saveEventually()
            
            // Archive last month's (actually all unarchived) transactions
            for transaction in transactions {
                transaction.archived = true;
            }
            
            // If the save worked, unpin all transactions
            return PFObject.unpinAllInBackground(transactions)
            
            
        }.continueWithBlock{ (task: BFTask!) -> AnyObject! in
            
            // Save all the transactions we've just archived
            PFObject.saveAllInBackground(transactions).continueWithSuccessBlock{ (_) in
                for transaction in transactions {
                    transaction.saveEventually()
                }
                return nil
            }
            
            if let c = callback {
                c(error: task.error)
            }
            return nil
        }
    }

    /**
    Fetch all Accounts modified since we last called this method
    
    :param: callback callback when data is availble (or error occured)
    */
    
    // TODO: Would like to implement this as an extension on all 
    // our model classes but this bug:
    // https://openradar.appspot.com/20119848
    // Prevents us getting at PFSubclassing.parseClassName from an extension.
    
    class func fetchModifications() ->BFTask! {
        if let user = PFUser.currentUser() {
            let query = PMUser.query()
            query?.includeKey("accounts")
            let keyName = "LastServerRefresh" + Account.parseClassName()
            if let lastFetch = NSUserDefaults.standardUserDefaults().objectForKey(keyName) as? NSDate {
                query?.whereKey("UpdatedAt", greaterThan: lastFetch)
            }
            
            return query?.getObjectInBackgroundWithId(user.objectId!).continueWithSuccessBlock{ (task:BFTask!) -> BFTask! in
                NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: keyName)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                let user = task.result as! PMUser
                return PFObject.pinAllInBackground(user.accounts as [AnyObject])
                
            }.continueWithBlock{ (task:BFTask!) -> BFTask! in

                // callback(error: task.error)
                return task
            }
            
        }
        else {
            let error = NSError(domain: "PocketMoney", code: 500, userInfo: [NSLocalizedDescriptionKey : "Not logged in"])
            // callback(error: error)
            return BFTask(error: error)
        }
    }

    
}

// MARK: - debug

extension Account : DebugPrintable, Printable {
    
    override var debugDescription : String {
        return self.description
    }
    
    override var description  : String {
        return super.description + "Account: \(name) : £\(balance)"
    }
    
}
