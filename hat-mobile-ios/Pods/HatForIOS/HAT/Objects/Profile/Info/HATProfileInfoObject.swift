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

public struct HATProfileInfo: HatApiType, Comparable {
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HATProfileInfo, rhs: HATProfileInfo) -> Bool {
        
        return (lhs.recordID == rhs.recordID)
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
    public static func < (lhs: HATProfileInfo, rhs: HATProfileInfo) -> Bool {
        
        return lhs.recordID < rhs.recordID
    }
    
    // MARK: - Fields
    
    private struct Fields {
        
        static let dateOfBirth: String = "dateOfBirth"
        static let gender: String = "gender"
        static let incomeGroup: String = "incomeGroup"
        static let recordId: String = "recordId"
        static let unixTimeStamp: String = "unixTimeStamp"
    }
    
    // MARK: - Variables
    
    public var dateOfBirth: Date = Date()
    
    public var gender: String = ""
    public var incomeGroup: String = ""
    public var recordID: String = "-1"
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        dateOfBirth = Date()
        
        gender = ""
        incomeGroup = ""
        recordID = "-1"
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dict: JSON) {
        
        if let data = (dict["data"].dictionary) {
            
            if let tempGender = (data[Fields.gender]?.stringValue) {
                
                gender = tempGender
            }
            
            if let tempIncomeGroup = (data[Fields.incomeGroup]?.stringValue) {
                
                incomeGroup = tempIncomeGroup
            }
            
            if let tempDateOfBirth = (data[Fields.dateOfBirth]?.intValue) {
                
                dateOfBirth = Date(timeIntervalSince1970: TimeInterval(tempDateOfBirth))
            }
        }
        
        recordID = (dict[Fields.recordId].stringValue)
    }
    
    /**
     It initialises everything from the received JSON file from the cache
     */
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        if let tempGender = fromCache[Fields.gender] {
            
            gender = String(describing: tempGender)
        }
        
        if let tempIncomeGroup = fromCache[Fields.incomeGroup] {
            
            incomeGroup = String(describing: tempIncomeGroup)
        }
        
        if let tempDateOfBirth = fromCache[Fields.dateOfBirth] {
            
            let temp = String(describing: tempDateOfBirth)
            dateOfBirth = Date(timeIntervalSince1970: TimeInterval(temp)!)
        }
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.dateOfBirth: HATFormatterHelper.formatDateToISO(date: self.dateOfBirth),
            Fields.gender: self.gender,
            Fields.incomeGroup: self.incomeGroup,
            Fields.unixTimeStamp: Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!
        ]

    }
}
