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

import HatForIOS
import SwiftyJSON

// MARK: Struct

internal struct InterestsObject: HatApiType {
    
    // MARK: - Fields
    struct Fields {
        
        static let values: String = "values"
    }

    // MARK: - Variables
    
    var dictionary: Dictionary<String, Any>
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        dictionary = [:]
    }
    
    /**
     It initialises everything from the received JSON file from the dictionary passed on
     */
    init(from: Dictionary<String, Any>) {
        
        dictionary = [:]
        let json = JSON(from)
        if let tempDictionary = json["data"].dictionary {
            
            for item in tempDictionary {
                
                dictionary.updateValue(item.value.intValue, forKey: item.key)
            }
        }
    }
    
    /**
     It initialises everything from the received JSON file from the cache
     */
    mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        if let tempValues = fromCache[Fields.values] {
            
            if let tempDictionary = tempValues as? Dictionary<String, Any> {
                
                dictionary = tempDictionary
                print(tempDictionary)
            }
        }
    }
    
    // MARK: - Convert to JSON
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    func toJSON() -> Dictionary<String, Any> {
        
        return [Fields.values: self.dictionary]
    }
}
