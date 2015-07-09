//
//  UIFont+proprotionalNumbers.swift
//  PocketMoney
//
//  Created by Roger Nolan on 08/07/2015.
//  Copyright (c) 2015 Babbage Consulting. All rights reserved.
//

import Foundation

extension UIFont {
    func copyWithTabularNumbers() -> UIFont {
        let featureArray = [
            [
                // Monospaced numbers
                UIFontFeatureTypeIdentifierKey: kNumberSpacingType,
                UIFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector
            ],
            [
                // Wide : for times and dates
                UIFontFeatureTypeIdentifierKey: kCharacterAlternativesType,
                UIFontFeatureSelectorIdentifierKey: 1
            ],
            [
                // round . available on Helvetica Neue.
                UIFontFeatureTypeIdentifierKey : kStyleOptionsType,
                UIFontFeatureSelectorIdentifierKey:  1
            ]
        ]

        let newFontDesc = fontDescriptor().fontDescriptorByAddingAttributes([UIFontDescriptorFeatureSettingsAttribute: featureArray])
        
        return UIFont(descriptor: newFontDesc, size: pointSize)
    }
}
