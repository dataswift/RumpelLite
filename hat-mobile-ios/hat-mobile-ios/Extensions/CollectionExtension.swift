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

// MARK: Extension

extension Array where Element == String {

    // MARK: - Remove from array
    
    /**
     Removes from array the given string if found
     
     - parameter string: The string to remove from the array
     */
    mutating func removeThe(string: String) {
        
        // check in the array
        var found = false
        var index = 0
        
        repeat {
            
            if self[index] == string {
                
                // remove the string
                self.remove(at: index)
                found = true
            } else {
                
                index += 1
            }
        } while found == false && index < self.count
    }
    
    // MARK: - Construct string
    
    /**
     Combines an Array of strings in one string
     
     - parameter array: The array that has all the strings we want to combine
     
     - returns: A String
     */
    func constructStringFromArray(array: [String]) -> String {
        
        // init a string
        var stringToReturn: String = ""
        
        // check if array is empty
        if !array.isEmpty {
            
            // go through the array
            for item in 0...array.count - 1 {
                
                // add the string to the stringToReturn
                stringToReturn = stringToReturn.appending(array[item] + ",")
            }
        }
        
        // return the string
        return stringToReturn
    }
}
