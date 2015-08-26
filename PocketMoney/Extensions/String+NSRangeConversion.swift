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
        let startIndex = self.startIndex.advancedBy(range.location)
        let endIndex = self.startIndex.advancedBy( range.length)
        return startIndex..<endIndex

    }
}

extension NSRange {
    func swiftRangeOn(string : String) -> Range<String.Index> {
        let startIndex = string.startIndex.advancedBy(self.location)
        let endIndex = string.startIndex.advancedBy( self.length)
        return startIndex..<endIndex
    }
}