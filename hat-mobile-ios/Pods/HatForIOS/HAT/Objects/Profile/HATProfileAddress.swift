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

import SwiftyJSON

public struct HATProfileAddress: HatApiType {
    
    // MARK: - Fields
    
    private struct Fields {
        
        static let streetAddress: String = "streetAddress"
        static let houseNumber: String = "houseNumber"
        static let postCode: String = "postCode"
    }
    
    // MARK: - Variables
    
    public var streetAddress: String = ""
    public var houseNumber: String = ""
    public var postCode: String = ""

    // MARK: - Initialisers
    
    public init() {
        
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dict: JSON) {
        
        self.initialize(dict: dict.dictionaryValue)
    }
    
    public mutating func initialize(dict: Dictionary<String, JSON>) {
        
        if let tempStreetAddress = (dict[Fields.streetAddress]?.stringValue) {
            
            streetAddress = tempStreetAddress
        }
        
        if let tempHouseNumber = (dict[Fields.houseNumber]?.stringValue) {
            
            houseNumber = tempHouseNumber
        }
        
        if let tempPostCode = (dict[Fields.postCode]?.stringValue) {
            
            postCode = tempPostCode
        }
    }
    
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let json = JSON(fromCache)
        self.initialize(dict: json.dictionaryValue)
    }
    
    // MARK: - To JSON
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, Any>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.streetAddress: self.streetAddress,
            Fields.houseNumber: self.houseNumber,
            Fields.postCode: self.postCode
        ]
    }
}
