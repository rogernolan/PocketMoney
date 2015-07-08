//
//  TransactionsListViewController.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit
// import Parse

class TransactionsListViewController: UITableViewController {

    var currentTransactions : [Transaction]?
    var historicTransactions : [Transaction]?
    var nextArchiveFetchSkip : Int = 0
    
    var account: Account? {

        didSet {
            // set the title
            self.configureView()
            // Update the model.

            loadTransactionsFromAccount()
        }
    }

    var dateFormatter: NSDateFormatter {
        struct Static {
            static let instance : NSDateFormatter = {
                let formatter = NSDateFormatter()
                formatter.dateStyle = .MediumStyle
                formatter.timeStyle = .NoStyle
                return formatter
                }()
        }
        
        return Static.instance
    }
    
    var currencyFormatter: NSNumberFormatter {
        struct Static {
            static let instance : NSNumberFormatter = {
                let formatter = NSNumberFormatter()
                formatter.numberStyle = .CurrencyStyle
                return formatter
                }()
        }
        
        return Static.instance
    }
    

    func configureView() {
        // Update the user interface for the detail item.
        if let ac = self.account {
            title = ac.name
        }
        tableView.reloadData();
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Loading")
        self.refreshControl?.addTarget(self, action: "pulledToRefresh", forControlEvents: .ValueChanged)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "modelUpdated:", name: ModelUpdatedNotification, object: nil)

        loadTransactionsFromAccount(fromServer:false)

    }
    
    deinit{
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func modelUpdated(_:NSNotification){
        loadTransactionsFromAccount()
    }
    
    func loadTransactionsFromAccount(fromServer:Bool = false) {
        if refreshControl?.refreshing != nil {
            refreshControl?.beginRefreshing()
            account?.currentTransactions(fromServer:fromServer).continueWithSuccessBlock { (task:BFTask!) in
                self.refreshControl?.endRefreshing()
                if let objects = task.result as? [Transaction] {
                    self.currentTransactions = objects
                    self.configureView()
                }
                return nil
            }
        }
    }
        
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if historicTransactions == nil {
            return 1
        }
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        switch section {
        case 0:
            var count = 0
            if let rows = currentTransactions {
                    count = rows.count
                }

            if count == 0 {
                count = 1   // Show the "no transactions cell
            }
            if historicTransactions == nil {
                count += 1  // Show load more
            }
            return count
        case 1:
            var count = historicTransactions!.count
            if count == 0 {
                count = 1
            }
            return count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Transactions"
        case 1:
            return "Previous Months"
        default:
            return ""
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = indexPath.row
        if indexPath.section == 0 {
            if currentTransactions!.count == 0 && row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("noneCell", forIndexPath: indexPath) as! UITableViewCell
                return cell
            }
            
            if row >= currentTransactions!.count && historicTransactions == nil {
                let cell = tableView.dequeueReusableCellWithIdentifier("loadMoreCell", forIndexPath: indexPath) as! LoadMoreCell
                cell.loadMoreButton.addTarget(self, action: "loadMore", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("transaction", forIndexPath: indexPath) as! TransactionCell
            if let transaction = currentTransactions?[row] {
                cell.nameLabel.text = transaction.name
                cell.amountLabel.text = currencyFormatter.stringFromNumber(transaction.amount)
                cell.dateLabel.text = dateFormatter.stringFromDate(transaction.date)
            }
            return cell

        } else {
            if historicTransactions!.count == 0 && row == 0 {
                let cell = tableView.dequeueReusableCellWithIdentifier("noneCell", forIndexPath: indexPath) as! UITableViewCell
                return cell
            }
            if row >= historicTransactions!.count {
                let cell = tableView.dequeueReusableCellWithIdentifier("loadMoreCell", forIndexPath: indexPath) as! LoadMoreCell
                cell.loadMoreButton.addTarget(self, action: "loadMore", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            }
            let cell = tableView.dequeueReusableCellWithIdentifier("transaction", forIndexPath: indexPath) as! TransactionCell
            if let transaction = historicTransactions?[row] {
                cell.nameLabel.text = transaction.name
                cell.amountLabel.text = "£\(transaction.amount)"
                cell.dateLabel.text = dateFormatter.stringFromDate(transaction.date)
            }
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, shouldShowMenuForRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row < currentTransactions!.count {
            return true
        }
        
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // stub. Without this on iOS8 the editing swipe is not shown.
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == 0 && indexPath.row < currentTransactions!.count {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if indexPath.section == 0 && indexPath.row < currentTransactions!.count {
            var deleteAction = UITableViewRowAction(style: .Default, title: "Delete") { (action, indexPath) -> Void in
                tableView.editing = false
                let t = self.currentTransactions?[indexPath.row]
                t?.deleteFromAccount().continueWithSuccessBlock({ (task) -> AnyObject! in
                    self.loadTransactionsFromAccount()

                    return nil
                })
            }
                
            return [deleteAction]
        }
        else {
            // Can't edit history
            return nil
        }

    }

    func pulledToRefresh() {
        loadTransactionsFromAccount(fromServer:true)
    }
    
    func loadMore(){
        account?.fetchArchivedTransactions(queryLimit : 100, skip: nextArchiveFetchSkip).continueWithBlock { (task: BFTask!) -> AnyObject! in
            if let t = task.result as? [Transaction] {
                if self.historicTransactions != nil {
                    self.historicTransactions! += t
                }
                else {
                    self.historicTransactions = t
                }
                self.tableView.reloadData()
                
            }
            else {
                // TODO: Error handling
                println("Error loading historic transactions: \(task.error)")
            }
            
            return nil
        }
    }
    
}

