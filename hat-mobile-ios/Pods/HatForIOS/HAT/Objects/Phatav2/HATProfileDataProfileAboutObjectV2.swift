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

public struct HATProfileDataProfileAboutObjectV2: HATObject, HatApiType {
    
    // MARK: - Fields
    
    struct Fields {
        
        static let body: String = "body"
        static let title: String = "title"
    }
    
    public var body: String = ""
    public var title: String = ""
    
    public init() {
        
    }
    
    public init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        self.initialize(dict: dict)
    }
    
    public mutating func initialize(dict: Dictionary<String, JSON>) {
    
        if let tempBody = (dict[Fields.body]?.stringValue) {
            
            body = tempBody
        }
        if let tempTitle = (dict[Fields.title]?.stringValue) {
            
            title = tempTitle
        }
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            Fields.body: self.body,
            Fields.title: self.title
        ]
    }
    
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let json = JSON(fromCache)
        self.initialize(dict: json.dictionaryValue)
    }
}
