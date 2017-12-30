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

public struct HATProfileDataProfileAddressObjectV2: HATObject, HatApiType {

    // MARK: - Fields
    
    struct Fields {
        
        static let city: String = "city"
        static let county: String = "county"
        static let country: String = "country"
    }
    
    public var city: String = ""
    public var county: String = ""
    public var country: String = ""
    
    public init() {
        
    }
    
    public init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        self.initialize(dict: dict)
    }
    
    public mutating func initialize(dict: Dictionary<String, JSON>) {
        
        if let tempCity = (dict[Fields.city]?.stringValue) {
            
            city = tempCity
        }
        if let tempCounty = (dict[Fields.county]?.stringValue) {
            
            county = tempCounty
        }
        if let tempCountry = (dict[Fields.country]?.stringValue) {
            
            country = tempCountry
        }
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            Fields.city: self.city,
            Fields.county: self.county,
            Fields.country: self.country
        ]
    }
    
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let json = JSON(fromCache)
        self.initialize(dict: json.dictionaryValue)
    }
}
