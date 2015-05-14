//
//  NewTransactionViewController.swift
//  PocketMoney
//
//  Created by roger nolan on 14/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit

class NewTransactionViewController: UITableViewController {

    var account : Account?
    
    @IBOutlet weak var amountEdit: UITextField!
    @IBOutlet weak var nameEdit: UITextField!
    @IBOutlet weak var endOfMonthSwitch: UISwitch!
    
    var lastTransactionName : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidDisappear(animated: Bool) {
        // Check that we are being dismissed from the top of the stack. Means back has been pressed and we should create a
        // new transaction
        if let description = self.nameEdit.text, ac = account, vcs = self.navigationController?.viewControllers as? [NSObject] {
            if contains(vcs, self) {
                if endOfMonthSwitch.on == true {
                    ac.endMonth(description, amount: self.amountEdit.text.doubleValue, callback: { (error) -> Void in
                        // code
                    })

                }
                else {
                    ac.addTransaction(description , amount: self.amountEdit.text.doubleValue)
                }
            }
        }
        super.viewDidDisappear(animated)
    }
    
    @IBAction func saveTapped(sender: AnyObject) {
        if let transactionTitle = self.nameEdit.text, ac = account {
            if endOfMonthSwitch.on == true {
                ac.endMonth(transactionTitle, amount: self.amountEdit.text.doubleValue, callback: { (error) -> Void in
                    // code
                })
            }
            else {
                ac.addTransaction(transactionTitle , amount: self.amountEdit.text.doubleValue)
            }
            self.navigationController?.popViewControllerAnimated(true)
        }

    }
    
    @IBAction func endOfMonthSwitched(sender: AnyObject) {
        if endOfMonthSwitch.on == true {
            lastTransactionName = nameEdit.text
            nameEdit.text = "End of Month"
            }
        else {
            if let s = lastTransactionName {
                nameEdit.text = s
            }
            else {
                nameEdit.text = ""
            }
        }
    }
    // MARK: - Table view data source

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath) as! UITableViewCell

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
}
