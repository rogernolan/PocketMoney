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

            self.account?.currentTransactions().continueWithSuccessBlock { (task:BFTask!) in
                if let objects = task.result as? [Transaction] {
                    self.currentTransactions = objects
                    self.configureView()
                }
                
                return nil
            }
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
    
    func configureView() {
        // Update the user interface for the detail item.
        if let ac = self.account {
            title = ac.name
        }
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            if let rows = currentTransactions {
                var count = rows.count
                if historicTransactions == nil {
                    count += 1
                }
                return count
            }
        case 1:
            return historicTransactions!.count
        default:
            return 0
        }


        // else no rows.
        return 0
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
            if row >= currentTransactions!.count && historicTransactions == nil {
                let cell = tableView.dequeueReusableCellWithIdentifier("loadMoreCell", forIndexPath: indexPath) as! LoadMoreCell
                cell.loadMoreButton.addTarget(self, action: "loadMore", forControlEvents: UIControlEvents.TouchUpInside)
                return cell
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier("transaction", forIndexPath: indexPath) as! TransactionCell
            if let transaction = currentTransactions?[row] {
                cell.nameLabel.text = transaction.name
                cell.amountLabel.text = "£\(transaction.amount)"
                cell.dateLabel.text = dateFormatter.stringFromDate(transaction.date)
            }
            return cell

        } else {
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

