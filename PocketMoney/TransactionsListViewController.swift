//
//  TransactionsListViewController.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit
import Parse

class TransactionsListViewController: UITableViewController {

    var account: Account? {
        didSet {
            // Update the view.
            account?.fetchIfNeededInBackgroundWithBlock({ (fetchedAccount: PFObject?, error: NSError?) -> Void in
                if error != nil {
                    self.configureView()
                }

            })
        }
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
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        if let rows = account?.transactions {
            return rows.count
        }
        // else no rows.
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("transaction", forIndexPath: indexPath) as! TransactionCell
        let row = indexPath.row
        if let transaction = account?.transactions?[row] {
            cell.nameLabel.text = transaction.name
            cell.amountLabel.text = "£\(transaction.amount)"
            
        }

        return cell
    }

}

