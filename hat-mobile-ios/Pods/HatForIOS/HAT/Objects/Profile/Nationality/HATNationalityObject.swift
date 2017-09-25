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

public struct HATNationalityObject: HatApiType, Comparable {
    
    // MARK: - Fields
    struct Fields {
        
        static let nationality: String = "nationality"
        static let passportHeld: String = "passportHeld"
        static let passportNumber: String = "passportNumber"
        static let placeOfBirth: String = "placeOfBirth"
        static let language: String = "language"
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
    public static func == (lhs: HATNationalityObject, rhs: HATNationalityObject) -> Bool {
        
        return (lhs.nationality == rhs.nationality && lhs.passportNumber == rhs.passportNumber && lhs.unixTimeStamp == rhs.unixTimeStamp)
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
    public static func < (lhs: HATNationalityObject, rhs: HATNationalityObject) -> Bool {
        
        return lhs.unixTimeStamp! < rhs.unixTimeStamp!
    }
    
    // MARK: - Variables
    
    /// Indicates if the object, HATProfileDataProfilePrimaryEmailObject, is private
    public var nationality: String = ""
    public var passportHeld: String = ""
    public var passportNumber: String = ""
    public var placeOfBirth: String = ""
    public var language: String = ""
    public var recordID: String = ""
    
    public var unixTimeStamp: Int?
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        nationality = ""
        passportHeld = ""
        passportNumber = ""
        placeOfBirth = ""
        language = ""
        recordID = ""
        unixTimeStamp = nil
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dict: JSON) {
        
        if let data = (dict[Fields.data].dictionary) {
            
            nationality = (data[Fields.nationality]!.stringValue)
            passportHeld = (data[Fields.passportHeld]!.stringValue)
            passportNumber = (data[Fields.passportNumber]!.stringValue)
            placeOfBirth = (data[Fields.placeOfBirth]!.stringValue)
            language = (data[Fields.language]!.stringValue)
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
        
        if let tempNationality = fromCache[Fields.nationality] {
            
            self.nationality = String(describing: tempNationality)
        }
        
        if let tempPassportHeld = fromCache[Fields.passportHeld] {
            
            self.passportHeld = String(describing: tempPassportHeld)
        }
        
        if let tempPassportNumber = fromCache[Fields.passportNumber] {
            
            self.passportNumber = String(describing: tempPassportNumber)
        }
        
        if let tempPlaceOfBirth = fromCache[Fields.placeOfBirth] {
            
            self.placeOfBirth = String(describing: tempPlaceOfBirth)
        }
        
        if let tempLanguage = fromCache[Fields.language] {
            
            self.language = String(describing: tempLanguage)
        }
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.nationality: self.nationality,
            Fields.passportHeld: self.passportHeld,
            Fields.passportNumber: self.passportNumber,
            Fields.placeOfBirth: self.placeOfBirth,
            Fields.language: self.language,
            Fields.unixTimeStamp: Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!
        ]
    }
    
}
