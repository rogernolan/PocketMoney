//
//  SharingHeaderCell.swift
//  PocketMoney
//
//  Created by Roger Nolan on 18/05/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit

class SharingHeaderCell: UITableViewCell {

    @IBOutlet weak var accountName: UILabel!
    @IBOutlet weak var balance: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
