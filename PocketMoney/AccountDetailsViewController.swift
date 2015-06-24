//
//  AccountDetailsViewController.swift
//  PocketMoney
//
//  Created by Roger Nolan on 18/05/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit

class AccountDetailsViewController: UITableViewController {

    var account : Account!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("DetailsHeaderCell") as! AccountDetailsHeaderCell
            cell.accountName.text = account.name
            cell.balance.text = "£\(account.balance)"
            return cell
        }
        
        // if indexPath.row > 1 {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddPersonCell") as! AddPersonCell
        cell.addButton.addTarget(self, action: "addPerson", forControlEvents:UIControlEvents.TouchUpInside)
        return cell
        
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        else {
            return "Contributors"
        }
    }

    /*
    // MARK: - Navigation
    */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "editAccount" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                (segue.destinationViewController as! EditAccountViewController).account = account
            }
        }
    }

    // MARK: - UI Events
    func addPerson() -> Void {
        let payload = ["email" : "rog@hatbat.net", "account" : account ]
        PFCloud.callFunctionInBackground("shareAccount", withParameters: payload).continueWithBlock { (task: BFTask!) -> BFTask in
            println("Error: \(task.error)")
            return task
        }
    }
}
