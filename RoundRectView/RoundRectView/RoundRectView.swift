//
//  RoundRectView.swift
//  RoundRectView
//
//  Created by roger nolan on 10/04/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import UIKit

@IBDesignable public class RoundRectView: UIView {

    @IBInspectable public var cornerRadius : CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }

    @IBInspectable public var fillColour: UIColor {
        set {
            layer.backgroundColor = newValue.CGColor

        }
        get {
            return UIColor(CGColor: layer.backgroundColor)!
        }
    }
}
