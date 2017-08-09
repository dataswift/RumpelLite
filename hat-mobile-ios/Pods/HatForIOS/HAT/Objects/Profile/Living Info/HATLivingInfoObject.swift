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

public struct HATLivingInfoObject: Comparable {
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HATLivingInfoObject, rhs: HATLivingInfoObject) -> Bool {
        
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
    public static func < (lhs: HATLivingInfoObject, rhs: HATLivingInfoObject) -> Bool {
        
        return lhs.recordID < rhs.recordID
    }
    
    // MARK: - Fields
    
    private struct Fields {
        
        static let relationshipStatus: String = "relationshipStatus"
        static let typeOfAccomodation: String = "typeOfAccomodation"
        static let livingSituation: String = "livingSituation"
        static let numberOfPeopleInHousehold: String = "numberOfPeopleInHousehold"
        static let numberOfDecendants: String = "numberOfDecendants"
        static let numberOfChildren: String = "numberOfChildren"
        static let recordId: String = "recordId"
        static let unixTimeStamp: String = "unixTimeStamp"
    }
    
    // MARK: - Variables
    
    public var relationshipStatus: String = ""
    public var typeOfAccomodation: String = ""
    public var livingSituation: String = "-1"
    public var numberOfPeopleInHousehold: String = ""
    public var numberOfDecendants: String = "-1"
    public var numberOfChildren: String = ""
    public var recordID: String = "-1"
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        relationshipStatus = ""
        typeOfAccomodation = ""
        livingSituation = ""
        numberOfPeopleInHousehold = ""
        numberOfDecendants = ""
        numberOfChildren = ""
        recordID = "-1"
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dict: JSON) {
        
        if let data = (dict["data"].dictionary) {
            
            if let tempRelationshipStatus = (data[Fields.relationshipStatus]?.stringValue) {
                
                relationshipStatus = tempRelationshipStatus
            }
            
            if let tempTypeOfAccomodation = (data[Fields.typeOfAccomodation]?.stringValue) {
                
                typeOfAccomodation = tempTypeOfAccomodation
            }
            
            if let tempLivingSituation = (data[Fields.livingSituation]?.stringValue) {
                
                livingSituation = tempLivingSituation
            }
            
            if let tempNumberOfPeopleInHousehold = (data[Fields.numberOfPeopleInHousehold]?.stringValue) {
                
                numberOfPeopleInHousehold = tempNumberOfPeopleInHousehold
            }
            
            if let tempNumberOfDecendants = (data[Fields.numberOfDecendants]?.stringValue) {
                
                numberOfDecendants = tempNumberOfDecendants
            }
            
            if let tempNumberOfChildren = (data[Fields.numberOfChildren]?.stringValue) {
                
                numberOfChildren = tempNumberOfChildren
            }
        }
        
        recordID = (dict[Fields.recordId].stringValue)
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.relationshipStatus: self.relationshipStatus,
            Fields.typeOfAccomodation: self.typeOfAccomodation,
            Fields.livingSituation: self.livingSituation,
            Fields.numberOfPeopleInHousehold: self.numberOfPeopleInHousehold,
            Fields.numberOfDecendants: self.numberOfDecendants,
            Fields.numberOfChildren: self.numberOfChildren,
            Fields.unixTimeStamp: Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!
        ]
        
    }
}
