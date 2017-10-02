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

// MARK: Struct

public struct StuffToRememberObject: HatApiType, Comparable {

    // MARK: - Fiels
    
    /// The possible Fields of the JSON struct
    struct Fields {
        
        static let title: String = "title"
        static let body: String = "body"
        static let unixTimeStamp: String = "unixTimeStamp"
        static let data: String = "data"
    }
    
    // MARK: - Comparable protocol methods
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func < (lhs: StuffToRememberObject, rhs: StuffToRememberObject) -> Bool {
        
        if lhs.unixTimeStamp != nil && rhs.unixTimeStamp != nil {
            
            return lhs.unixTimeStamp! < rhs.unixTimeStamp!
        }
        
        return false
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: StuffToRememberObject, rhs: StuffToRememberObject) -> Bool {
        
        return (lhs.body == rhs.body && lhs.title == rhs.title && lhs.unixTimeStamp == rhs.unixTimeStamp)
    }
    
    // MARK: - Variables
    
    public var title: String = ""
    public var body: String = ""
    
    public var unixTimeStamp: Int?
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        title = ""
        body = ""
        
        unixTimeStamp = nil
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        if let tempData = dictionary[Fields.data]?.dictionaryValue {
            
            if let tempBody = tempData[Fields.body]?.stringValue {
                
                self.body = tempBody
            }
            
            if let tempTitle = tempData[Fields.title]?.stringValue {
                
                self.title = tempTitle
            }
            
            if let tempUnixTimeStamp = tempData[Fields.unixTimeStamp]?.intValue {
                
                self.unixTimeStamp = tempUnixTimeStamp
            }
        }
    }
    
    /**
     It initialises everything from the received JSON file from the cache
     */
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        if let tempBody = fromCache[Fields.body] {
            
            self.body = String(describing: tempBody)
        }
        
        if let tempTitle = fromCache[Fields.title] {
            
            self.title = String(describing: tempTitle)
        }
        
        if let tempUnixTimeStamp = fromCache[Fields.unixTimeStamp] as? Int {
            
            self.unixTimeStamp = tempUnixTimeStamp
        }
    }
    
    // MARK: - To JSON
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            Fields.body: self.body,
            Fields.title: self.title,
            Fields.unixTimeStamp: Date().timeIntervalSince1970
        ]
    }
}
