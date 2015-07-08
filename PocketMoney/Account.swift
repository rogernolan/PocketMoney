//
//  Account.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

// import Parse
let ModelUpdatedNotification = "ModelUpdatedNotification"

enum Source {
    case server, local
}

class Account : PFObject, PFSubclassing {
    @NSManaged var balance : Double
    @NSManaged var openingBalance : Double
    @NSManaged var thisMonthOpeneingBalance : Double
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
        openingBalance = aBalance
        thisMonthOpeneingBalance = aBalance
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
            let query = PMUser.query()!
            query.includeKey("accounts")
            if source == .local {
                query.fromLocalDatastore()
            }
            return query.getObjectInBackgroundWithId(user.objectId!).continueWithBlock{ (task:BFTask!) -> BFTask! in
                if let e = task.error {
                    //Error Domain=Parse Code=120 not an error? means does not exist yet?
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
    Find all transactions for the given account
    
    :param: anAccount the account to retrieve the transactions for
    :param: callback  callback called when the find completes
    
    :returns: a Bolt task for the search
    */
    func currentTransactions(fromServer:Bool = false) ->BFTask {
        let pred = NSPredicate(format: "account = %@", self)
        let query = Transaction.queryWithPredicate(pred)!
        query.whereKey("deleted", equalTo:false)
        if fromServer == false {
            query.fromLocalDatastore()
        }
        return query.findObjectsInBackground()
    }
    
    
    func fetchArchivedTransactions(queryLimit : Int = 100, skip : Int = 0) -> BFTask! {
        let pred = NSPredicate(format: "account = %@", self)
        let query = Transaction.queryWithPredicate(pred)!

        query.limit = queryLimit
        query.skip = skip
        query.orderByAscending("createdAt")
        query.whereKey("archived", equalTo:true)
        query.whereKey("deleted", equalTo:false)

        return query.findObjectsInBackground()
    }
    
    
    /**
    Add a transaction to an account. Will auto decrement the balance
    
    :param: name         Name of the tranasaction
    :param: amount       the amount of the transaction
    */
    func addTransaction(name:String, amount:Double) -> BFTask!{
        let transaction = Transaction(account: self, name: name, amount: amount)
        
        let task = transaction.pinInBackground().continueWithSuccessBlock { (pinTask:BFTask!) -> BFTask! in
            transaction.saveEventually()
            return pinTask
        }.continueWithBlock { (pinnedTask:BFTask!) -> BFTask! in
            if pinnedTask.error == nil {
                self.balance -= amount
                self.saveInBackground().continueWithBlock{ (saveTask:BFTask!) -> AnyObject! in
                    NSNotificationCenter.defaultCenter().postNotificationName(ModelUpdatedNotification, object: self)
                    if saveTask.error != nil {
                        self.saveEventually()
                    }
                    return saveTask
                }
            }
            return pinnedTask
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName(ModelUpdatedNotification, object: self)

        return task
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
       return self.currentTransactions().continueWithSuccessBlock{ (task: BFTask!) -> BFTask in
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
                pinnedObject.saveInBackground().continueWithBlock{ (saveTask:BFTask!) -> AnyObject! in
                    if saveTask.error != nil {
                        pinnedObject.saveEventually()
                    }
                    return saveTask
                }
            }
            else {
                return BFTask(error: NSError(domain: "PocketMoney", code: 500, userInfo: nil))
            }
            // Now we are sure the transaction is saved, add the balance.
            self.balance += amount
            self.thisMonthOpeneingBalance = self.balance
            return self.saveInBackground().continueWithBlock{ (saveTask:BFTask!) -> AnyObject! in
                if saveTask.error != nil {
                    self.saveEventually()
                }
                return saveTask
            }
        }.continueWithSuccessBlock{ (task:BFTask!) -> AnyObject! in
    
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
                    transaction.saveInBackground().continueWithBlock{ (saveTask:BFTask!) -> AnyObject! in
                        if saveTask.error != nil {
                            self.saveEventually()
                        }
                        return saveTask;
                    }
                }
                return nil
            }
            
            if let c = callback {
                c(error: task.error)
            }
            NSNotificationCenter.defaultCenter().postNotificationName(ModelUpdatedNotification, object: self)

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

                NSNotificationCenter.defaultCenter().postNotificationName(ModelUpdatedNotification, object: self)
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
