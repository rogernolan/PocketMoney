//
//  UIColor+getRGB.swift
//  PocketMoney
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    func getRGB() -> (red:CGFloat, green:CGFloat, blue:CGFloat, alpha:CGFloat) {
    
        var red : CGFloat =  0.0
        var green : CGFloat = 0.0
        var blue : CGFloat = 0.0
        var alpha : CGFloat = 0.0
        
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green,blue, alpha)
    }
}
