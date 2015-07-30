//
//  String+numberValues
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import Foundation

extension String {
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
}