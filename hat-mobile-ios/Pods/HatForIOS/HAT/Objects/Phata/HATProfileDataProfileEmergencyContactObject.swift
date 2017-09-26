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

/// A struct representing the profile data Emergency Contact object from the received profile JSON file
public struct HATProfileDataProfileEmergencyContactObject: Comparable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    struct Fields {
        
        static let isPrivate: String = "private"
        static let isPrivateID: String = "privateID"
        static let firstName: String = "first_name"
        static let firstNameID: String = "firstNameID"
        static let lastName: String = "last_name"
        static let lastNameID: String = "lastNameID"
        static let relationship: String = "relationship"
        static let relationshipID: String = "relationshipID"
        static let mobile: String = "mobile"
        static let mobileID: String = "mobileID"
        static let name: String = "name"
        static let fieldID: String = "id"
        static let values: String = "values"
        static let value: String = "value"
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
    public static func == (lhs: HATProfileDataProfileEmergencyContactObject, rhs: HATProfileDataProfileEmergencyContactObject) -> Bool {
        
        return (lhs.isPrivate == rhs.isPrivate && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName && lhs.relationship == rhs.relationship && lhs.mobile == rhs.mobile)
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
    public static func < (lhs: HATProfileDataProfileEmergencyContactObject, rhs: HATProfileDataProfileEmergencyContactObject) -> Bool {
        
        return lhs.lastName < rhs.lastName
    }
    
    // MARK: - Variables
    
    /// Indicates if the object, HATProfileDataProfileEmergencyContactObject, is private
    public var isPrivate: Bool = true {
        
        didSet {
            
            isPrivateTuple = (isPrivate, isPrivateTuple.1)
        }
    }
    
    /// The first name of the user's emergency contact
    public var firstName: String = "" {
        
        didSet {
            
            firstNameTuple = (firstName, firstNameTuple.1)
        }
    }
    /// The last name of the user's emergency contact
    public var lastName: String = "" {
        
        didSet {
            
            lastNameTuple = (lastName, lastNameTuple.1)
        }
    }
    /// The user's relationship with the emergency contact
    public var relationship: String = "" {
        
        didSet {
            
            relationshipTuple = (relationship, relationshipTuple.1)
        }
    }
    /// The mobile number of the user's emergency contact
    public var mobile: String = "" {
        
        didSet {
            
            mobileTuple = (mobile, mobileTuple.1)
        }
    }
    
    /// A tuple containing the isPrivate and the ID of the value
    var isPrivateTuple: (Bool, Int) = (true, 0)
    
    /// A tuple containing the value and the ID of the value
    var firstNameTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the value and the ID of the value
    var lastNameTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the value and the ID of the value
    var relationshipTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the value and the ID of the value
    var mobileTuple: (String, Int) = ("", 0)
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        isPrivate = true
        firstName = ""
        lastName = ""
        relationship = ""
        mobile = ""
        
        isPrivateTuple = (true, 0)
        firstNameTuple = ("", 0)
        lastNameTuple = ("", 0)
        relationshipTuple = ("", 0)
        mobileTuple = ("", 0)
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from array: [JSON]) {
        
        for json in array {
            
            let dict = json.dictionaryValue
            
            if let tempName = (dict[Fields.name]?.stringValue), let id = dict[Fields.fieldID]?.intValue {
                
                if tempName == "private" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            if let result = Bool(stringValue) {
                                
                                isPrivate = result
                                isPrivateTuple = (isPrivate, id)
                            }
                        }
                    }
                }
                
                if tempName == "first_name" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            firstName = stringValue
                            firstNameTuple = (firstName, id)
                        }
                    }
                }
                
                if tempName == "last_name" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            lastName = stringValue
                            lastNameTuple = (lastName, id)
                        }
                    }
                }
                
                if tempName == "relationship" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            relationship = stringValue
                            relationshipTuple = (relationship, id)
                        }
                    }
                }
                
                if tempName == "mobile" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            mobile = stringValue
                            mobileTuple = (mobile, id)
                        }
                    }
                }
            }
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(alternativeArray: [JSON]) {
        
        for json in alternativeArray {
            
            let dict = json.dictionaryValue
            
            if let tempName = (dict[Fields.name]?.stringValue), let id = dict[Fields.fieldID]?.intValue {
                
                if tempName == Fields.isPrivate {
                    
                    isPrivate = true
                    isPrivateTuple = (isPrivate, id)
                }
                
                if tempName == Fields.firstName {
                    
                    firstName = ""
                    firstNameTuple = (firstName, id)
                }
                
                if tempName == Fields.lastName {
                    
                    lastName = ""
                    lastNameTuple = (lastName, id)
                }
                
                if tempName == Fields.relationship {
                    
                    relationship = ""
                    relationshipTuple = (relationship, id)
                }
                
                if tempName == Fields.mobile {
                    
                    mobile = ""
                    mobileTuple = (mobile, id)
                }
            }
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init (fromCache: Dictionary<String, JSON>) {
        
        if let tempPrivate = (fromCache[Fields.isPrivate]?.stringValue) {
            
            if let isPrivateResult = Bool(tempPrivate) {
                
                isPrivate = isPrivateResult
            }
        }
        
        if let tempPrivateID = (fromCache[Fields.isPrivateID]?.intValue) {
            
            isPrivateTuple = (isPrivate, tempPrivateID)
        }
        
        if let tempFirstName = (fromCache[Fields.firstName]?.stringValue) {
            
            firstName = tempFirstName
        }
        
        if let tempFirstNameID = (fromCache[Fields.firstNameID]?.intValue) {
            
            firstNameTuple = (firstName, tempFirstNameID)
        }
        
        if let tempLastName = (fromCache[Fields.lastName]?.stringValue) {
            
            lastName = tempLastName
        }
        
        if let tempLastNameID = (fromCache[Fields.lastNameID]?.intValue) {
            
            lastNameTuple = (lastName, tempLastNameID)
        }
        
        if let tempRelationship = (fromCache[Fields.relationship]?.stringValue) {
            
            relationship = tempRelationship
        }
        
        if let tempRelationship = (fromCache[Fields.relationship]?.intValue) {
            
            relationshipTuple = (relationship, tempRelationship)
        }
        
        if let tempMobile = (fromCache[Fields.mobile]?.stringValue) {
            
            mobile = tempMobile
        }
        
        if let tempMobileID = (fromCache[Fields.mobileID]?.intValue) {
            
            mobileTuple = (mobile, tempMobileID)
        }
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.isPrivate: String(describing: self.isPrivate),
            Fields.isPrivateID: self.isPrivateTuple.1,
            Fields.firstName: self.firstName,
            Fields.firstNameID: self.firstNameTuple.1,
            Fields.lastName: self.lastName,
            Fields.lastNameID: self.lastNameTuple.1,
            Fields.relationship: self.relationship,
            Fields.relationshipID: self.relationshipTuple.1,
            Fields.mobile: self.mobile,
            Fields.mobileID: self.mobileTuple.1
        ]
    }
    
}
