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

// MARK: Protocol

import SwiftyJSON

public protocol HATObject: Codable {

    /**
     Decodes a JSON file to a HATFitbitWeightObject
     
     - parameter from: A JSON object to decode from
     - returns: An optional HATFitbitWeightObject decoded from the JSON passed in as a parameter
     */
    static func decode<T: HATObject>(from: Dictionary<String, JSON>) -> T?
    
    func extractContent(from: JSON) -> Dictionary<String, JSON>
}

extension HATObject {
    
    public func extractContent(from: JSON) -> Dictionary<String, JSON> {
        
        return from.dictionaryValue
    }
    
    static public func decode<T: HATObject>(from: Dictionary<String, JSON>) -> T? {
        
        let decoder = JSONDecoder()
        
        do {
            
            let data = try JSON(from).rawData()
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            
            print("error decoding")
            return nil
        }
    }
}
