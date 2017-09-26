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

public struct HATProfileEducationObject: HatApiType, Comparable {
    
    // MARK: - Fields
    struct Fields {
        
        static let highestAcademicQualification: String = "highestAcademicQualification"
        static let unixTimeStamp: String = "unixTimeStamp"
        static let data: String = "data"
        static let recordID: String = "recordId"
    }
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HATProfileEducationObject, rhs: HATProfileEducationObject) -> Bool {
        
        return (lhs.highestAcademicQualification == rhs.highestAcademicQualification && lhs.unixTimeStamp == rhs.unixTimeStamp)
    }
    
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
    public static func < (lhs: HATProfileEducationObject, rhs: HATProfileEducationObject) -> Bool {
        
        return lhs.unixTimeStamp! < rhs.unixTimeStamp!
    }
    
    // MARK: - Variables
    
    public var highestAcademicQualification: String = ""
    public var recordID: String = ""
    
    public var unixTimeStamp: Int?
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        highestAcademicQualification = ""
        recordID = ""
        unixTimeStamp = nil
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dict: JSON) {
        
        if let data = (dict[Fields.data].dictionary) {
            
            highestAcademicQualification = (data[Fields.highestAcademicQualification]!.stringValue)
            if let time = (data[Fields.unixTimeStamp]?.stringValue) {
                
                unixTimeStamp = Int(time)
            }
        }
        
        recordID = (dict[Fields.recordID].stringValue)
    }
    
    /**
     It initialises everything from the received JSON file from the cache
     */
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        if let tempQualification = fromCache[Fields.highestAcademicQualification] {
            
            self.highestAcademicQualification = String(describing: tempQualification)
        }
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.highestAcademicQualification: self.highestAcademicQualification,
            Fields.unixTimeStamp: Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!
        ]
        
    }
}
