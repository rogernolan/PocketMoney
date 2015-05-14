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

    class func parseClassName() -> String {
        return "Transaction"
    }
    
    override init() {

        super.init()

    }
    
    convenience init(account anAccount:Account, name aName:String, amount anAmount:Double) {
        
        self.init()
        archived = false
        name = aName
        account = anAccount
        amount = anAmount
        date = NSDate()

    }

    /**
    Find all transactions for the given account
    
    :param: anAccount the account to retrieve the transactions for
    :param: callback  callback called when the find completes
    
    :returns: a Bolt task for the search
    */
    class func transactionsForAccount(account anAccount:Account) ->BFTask {
        let pred = NSPredicate(format: "account = %@", anAccount)
        let query = Transaction.queryWithPredicate(pred)!
        query.fromLocalDatastore()
        return query.findObjectsInBackground()
    }
    
    // TODO: Would like to implement this as an extension on all
    // our model classes but this bug:
    // https://openradar.appspot.com/20119848
    // Prevents us getting at PFSubclassing.parseClassName from an extension.
    
    class func fetchModifications() -> BFTask {
        let query = PFQuery(className:self.parseClassName())
        
        if let lastFetch = NSUserDefaults.standardUserDefaults().objectForKey("LastServerRefresh" + Account.parseClassName()) as? NSDate {
            query.whereKey("UpdatedAt", greaterThan: lastFetch)
        }
        query.orderByAscending("UpdatedAt")
        
        if let user = PFUser.currentUser() {
            let query = PFQuery(className:Account.parseClassName())
            // query.whereKey("owner", equalTo: user)
            query.limit = 100
            return query.findObjectsInBackground().continueWithSuccessBlock({ (task : BFTask!) -> AnyObject! in
                if let objects = task.result as? [PFObject] {
                    for o in objects { o.pin() }
                }
                
                return task.result
            })
        }
        let error = NSError(domain: "PocketMoney", code: 0, userInfo: [NSLocalizedDescriptionKey : "Not logged in"])
        return BFTask(result: error )
  
    }
}
