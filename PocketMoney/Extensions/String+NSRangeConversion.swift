//
//  String+NSRangeConversion.swift
//  PocketMoney
//
//  Created by Roger Nolan on 30/07/2015.
//  Copyright © 2015 Babbage Consulting. All rights reserved.
//

import Foundation
extension String {
    func swiftRangeFrom(range : NSRange) -> Range<Index> {
        let startIndex = advance(self.startIndex, range.location)
        let endIndex = advance(self.startIndex, range.length)
        return startIndex..<endIndex

    }
}