//
//  PMUser.swift
//  PocketMoney
//
//  Created by Roger Nolan on 28/05/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import Foundation

class PMUser : PFUser, PFSubclassing {
    @NSManaged var accounts : PFRelation
}