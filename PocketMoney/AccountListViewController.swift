//
//  MasterViewController.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit
// import Parse

class AccountListViewController: UITableViewController {

    var accounts = [Account]()

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkAndPresentLogin()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Loading")
        self.refreshControl?.addTarget(self, action: "pulledToRefresh", forControlEvents: .ValueChanged)
        self.refreshControl?.tintColor = UIColor.blackColor()
        loadModelObjects()
    }

    func checkAndPresentLogin(){
        
        if PFUser.currentUser() != nil {
            loadModelObjects()
        }
        
        if PFUser.currentUser() == nil {
            // No user logged in
            // Create the log in view controller
            let logInViewController = LoginViewController();
            logInViewController.fields = ( .UsernameAndPassword | .PasswordForgotten | .LogInButton |
                                        .Facebook | .Twitter | .SignUpButton)

            logInViewController.delegate = self
            
            // Create the sign up view controller
            let signUpViewController = SignUpViewController()
            signUpViewController.delegate = self
            
            // Assign our sign up controller to be displayed from the login controller
            logInViewController.signUpController = signUpViewController
            
            // Present the log in view controller
            self.presentViewController(logInViewController, animated:true, completion:nil)
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "showTransactions" {
//            CGPoint buttonPosition = [sender convertPoint:CGPointZero
//                toView:self.tableView];
//            NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
            if let buttonPos = (sender as? UIButton)?.convertPoint(CGPointZero, toView: tableView),
                indexPath = self.tableView.indexPathForRowAtPoint(buttonPos) {
                    let account = accounts[indexPath.row]
                    (segue.destinationViewController as! TransactionsListViewController).account = account
            }
        }
        
        if segue.identifier == "newTransaction" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let account = accounts[indexPath.row]
                (segue.destinationViewController as! NewTransactionViewController).account = account
            }
        }
        
        if segue.identifier == "sharingDetails" {
            if let indexPath = self.tableView.indexPathForSelectedRow() {
                let account = accounts[indexPath.row]
                (segue.destinationViewController as! SharingViewController).account = account
            }
        }
  }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return accounts.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Account", forIndexPath: indexPath) as! AccountCell

        let account = accounts[indexPath.row]
        cell.configureForAccount(account)
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    
//    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            objects.removeAtIndex(indexPath.row)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        } else if editingStyle == .Insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
//        }
//    }
    
    func loadModelObjects() {
                
        Account.loadFrom(.local, callback : { accounts, error in
            
            if let a = accounts {
                self.accounts = a
                if count(a) == 0 {
                    self.refreshFromServer()
                } else {
                    self.tableView.reloadData()                    
                }
            }
        })
    }

    func refreshFromServer() {
        
        tableView.userInteractionEnabled = false
        self.refreshControl?.beginRefreshing()
        Account.loadFrom(.server, callback : { accounts, error in
            self.tableView.userInteractionEnabled = true
            self.refreshControl?.endRefreshing()

            if error == nil {
                if let a = accounts {
                    self.accounts = a
                    self.tableView.reloadData()
                }
            }

        })
    }
    
    func pulledToRefresh() {
        refreshFromServer()
    }
    
    // MARK: Segues and navigation
    
    @IBAction func unwindToAccountListViewController(segue: UIStoryboardSegue) {
    }

}

extension AccountListViewController : PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        refreshFromServer()

        self.dismissViewControllerAnimated(true, completion: { () -> Void in
        })
    }
    
    func signUpViewController(signUpController: PFSignUpViewController, didSignUpUser user: PFUser) {
        // create a new account.
        
        let account = Account(name: "My first account", balance: 0.0, user:user)
        loadModelObjects()
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            //
        })


    }

}
