//
//  InterfaceController.swift
//  PocketMoney WatchKit Extension
//
//  Created by Roger Nolan on 22/06/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var accountTable: WKInterfaceTable!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        accountTable.setNumberOfRows(3, withRowType: "AccountRow")
        
        for i in 0...2 {
            let row = accountTable.rowControllerAtIndex(i) as! AccountRow
            row.name.setText("account \(i)")
        }
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
