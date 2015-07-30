//
//  Transaction.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

// import Parse

class Transaction: PFObject, PFSubclassing {
    @NSManaged var amount: Double
    @NSManaged var name : String
    @NSManaged var date : NSDate
    @NSManaged var archived : Bool
    @NSManaged var account: Account?
    @NSManaged var endOfMonth : Bool
    @NSManaged var deleted : Bool

    class func parseClassName() -> String {
        return "Transaction"
    }
    
    override init() {
        super.init()

    }
    
    convenience init(account anAccount:Account, name aName:String, amount anAmount:Double) {
        
        self.init()

        archived = false
        deleted = false
        
        name = aName
        account = anAccount
        amount = anAmount
        date = NSDate()

    }

    // TODO: Would like to implement this as an extension on all
    // our model classes but this bug:
    // https://openradar.appspot.com/20119848
    // Prevents us getting at PFSubclassing.parseClassName from an extension.
    
    class func fetchModifications() -> BFTask {
        if PFUser.currentUser() == nil {
            let error = NSError(domain: "PocketMoney", code: 0, userInfo: [NSLocalizedDescriptionKey : "Not logged in"])
            return BFTask(result: error )
        }
        
        let accountQuery = PFQuery(className:Account.parseClassName())
        accountQuery.fromLocalDatastore()
        
        return accountQuery.findObjectsInBackground().continueWithBlock { (task:BFTask!) -> AnyObject! in
            if let accounts = task.result as? [Account] {
                let query = PFQuery(className:self.parseClassName())
                let keyName = "LastServerRefresh" + Transaction.parseClassName()
                
                query.whereKey("account", containedIn:accounts)
                
                if let lastFetch = NSUserDefaults.standardUserDefaults().objectForKey(keyName) as? NSDate {
                    query.whereKey("UpdatedAt", greaterThan: lastFetch)
                }
                query.orderByAscending("UpdatedAt")
                
                
                return query.findObjectsInBackground().continueWithSuccessBlock({ (task : BFTask!) -> AnyObject! in
                    var keepers = [Transaction]()
                    if let objects = task.result as? [Transaction] {
                        keepers = objects.filter{(includeElement: Transaction) -> Bool in
                            return !includeElement.deleted }
                        NSUserDefaults.standardUserDefaults().setObject(NSDate(), forKey: keyName)
                        NSUserDefaults.standardUserDefaults().synchronize()
                        
                        return PFObject.pinAllInBackground(keepers)
                    }
                    
                    return keepers
                })
            }
            return task;
        }
  
    }
    
    func deleteFromAccount() -> BFTask! {
        let refund = self.amount
        self.deleted = true
        if let refreshedAccount = self.account {
            return refreshedAccount.fetchIfNeededInBackground().continueWithSuccessBlock{ (task : BFTask!) -> BFTask! in
                return self.unpinInBackground()
            }.continueWithSuccessBlock{ (task : BFTask!) -> BFTask! in
                return self.saveInBackground()
            }.continueWithBlock{ (saveTask : BFTask!) -> BFTask! in
                if saveTask.error != nil {
                    self.saveEventually()
                }
                return saveTask
            }.continueWithSuccessBlock{ (task : BFTask!) -> BFTask! in
                refreshedAccount.balance += refund
                return refreshedAccount.saveInBackground()
            }.continueWithSuccessBlock{ (task : BFTask!) -> AnyObject! in
                if task.error != nil {
                    refreshedAccount.saveEventually()
                }
                NSNotificationCenter.defaultCenter().postNotificationName(ModelUpdatedNotification, object: self)

                return nil
            }
        }
        else {
            return BFTask(error: NSError(domain: "PocketMoney", code: 500, userInfo: nil))
        }

    }
}
