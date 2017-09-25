/**
 * Copyright (C) 2017 HAT Data Exchange Ltd
 *
 * SPDX-License-Identifier: MPL2
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/
 */

import UIKit

// MARK: Extension

extension String {
    
    // MARK: - Generate random string
    
    /**
     Generates a random alphanumeric string
     
     - parameter length: The desired length of the random string
     
     - returns: A random String
     */
    static func random(length: Int = 20) -> String {
        
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""
        
        for _ in 0..<length {
            
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.index(base.startIndex, offsetBy: Int(randomValue))])"
        }
        
        return randomString
    }
    
    // MARK: - Convert from base64URL to base64
    
    /**
     String extension to convert from base64Url to base64
     
     - parameter stringToConvert: The string to be converted
     
     - returns: A Base64 String
     */
    func fromBase64URLToBase64(stringToConvert: String) -> String {
        
        var convertedString = stringToConvert
        if convertedString.characters.count % 4 == 2 {
            
            convertedString += "=="
        } else if convertedString.characters.count % 4 == 3 {
            
            convertedString += "="
        }
        
        convertedString = convertedString.replacingOccurrences(of: "-", with: "+")
        convertedString = convertedString.replacingOccurrences(of: "_", with: "/")
        
        return convertedString
    }
    
    // MARK: - Split a comma separated string to an Array of String
    
    /**
     Transforms a comma seperated string into an array
     
     - returns: [String]
     */
    func stringToArray() -> [String] {
        
        let trimmedString = self.replacingOccurrences(of: " ", with: "")
        var array = trimmedString.components(separatedBy: ",")
        
        if array.last == "" {
            
            array.removeLast()
        }
        
        return array
    }
    
    // MARK: - Trim string
    
    /**
     Trims a given String
     
     - returns: trimmed String
     */
    func trimString() -> String {
        
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    // MARK: - Text Attributes
    
    /**
     Creates an attributed string from the parameters passed
     
     - parameter foregroundColor: Foreground color of the string
     - parameter strokeColor: stroke color of the string
     - parameter font: the desired font for the string
     
     - returns: An attributed string formatted according to the parameters
     */
    func createTextAttributes(foregroundColor: UIColor, strokeColor: UIColor, font: UIFont) -> NSAttributedString {
        
        //swiftlint:disable force_cast
        let textAttributes = [
            NSAttributedStringKey.foregroundColor.rawValue: foregroundColor,
            NSAttributedStringKey.strokeColor: strokeColor,
            NSAttributedStringKey.font: font,
            NSAttributedStringKey.strokeWidth: -1.0
            ] as! [NSAttributedStringKey : Any]
        //swiftlint:enable force_cast

        return NSAttributedString(string: self, attributes: textAttributes)
    }
    
}
