//
//  AccountCell.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit
import RoundRectView

class AccountCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var background: RoundRectView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setColour(colour: UIColor) {
        background.fillColour = colour

        var red : CGFloat =  0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        
        (red, green, blue, _ ) = colour.getRGB()
    
        let compRed = 1.0 - red
        let compBlue = 1.0 - blue
        let compGreed = 1.0 - green
        
        let textColour = UIColor(red: compRed, green: compGreed, blue: compBlue, alpha: 1.0)
        nameLabel.textColor = textColour
        amountLabel.textColor = textColour
        
    }

    func configureForAccount(account:Account) {
        nameLabel.text = account.name
        amountLabel.text = "£\(account.balance)"
    }
}
