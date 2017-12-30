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

public struct HATLocationsV2Object: HATObject, HatApiType {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let locationID: String = "id"
        static let recordID: String = "recordId"
        static let endPoint: String = "endpoint"
        static let lastUpdated: String = "lastUpdated"
        static let locations: String = "locations"
        static let data: String = "data"
        static let name: String = "name"
        static let unixTimeStamp: String = "unixTimeStamp"
    }
    
    public var data: HATLocationsV2DataObject = HATLocationsV2DataObject()
    
    public init() {
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dict: Dictionary<String, JSON>) {
        
        // check for values and assign them if not empty
        if let tempData = dict[Fields.data]?.dictionaryValue {
            
            data = HATLocationsV2DataObject(dict: tempData)
        }
    }
    
    /**
     It initialises everything from the received JSON file from the cache
     */
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let dictionary = JSON(fromCache)
        self.initialize(from: dictionary.dictionaryValue)
    }
    
    /**
     It initialises everything from the received JSON file from the cache
     */
    public mutating func initialize(from dictionary: Dictionary<String, JSON>) {
        
        // this field will always have a value no need to use if let
        if let tempTables = dictionary[Fields.data]?.dictionaryValue {
            
            data = HATLocationsV2DataObject(dict: tempTables)
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT using V2 API
     */
    public init(dictV2: Dictionary<String, JSON>) {
        
        // init optional JSON fields to default values
        self.init()
        
        if let tempTables = dictV2[Fields.data]?.dictionaryValue {
            
            data = HATLocationsV2DataObject(dict: tempTables)
        }
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.data: self.data.toJSON()
        ]
    }
}
