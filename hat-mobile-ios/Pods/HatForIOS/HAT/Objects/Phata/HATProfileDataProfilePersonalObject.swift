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

/// A struct representing the profile data Personal object from the received profile JSON file
public struct HATProfileDataProfilePersonalObject: Comparable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    struct Fields {
        
        static let isPrivate: String = "private"
        static let isPrivateID: String = "privateID"
        static let firstName: String = "first_name"
        static let firstNameID: String = "firstNameID"
        static let lastName: String = "last_name"
        static let lastNameID: String = "lastNameID"
        static let preferredName: String = "preferred_name"
        static let preferredNameID: String = "preferredNameID"
        static let middleName: String = "middle_name"
        static let middleNameID: String = "middleNameID"
        static let title: String = "title"
        static let titleID: String = "titleID"
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
    public static func == (lhs: HATProfileDataProfilePersonalObject, rhs: HATProfileDataProfilePersonalObject) -> Bool {
        
        return (lhs.isPrivate == rhs.isPrivate && lhs.firstName == rhs.firstName && lhs.lastName == rhs.lastName && lhs.middleName == rhs.middleName && lhs.prefferedName == rhs.prefferedName && lhs.title == rhs.title)
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
    public static func < (lhs: HATProfileDataProfilePersonalObject, rhs: HATProfileDataProfilePersonalObject) -> Bool {
        
        return lhs.lastName < rhs.lastName
    }
    
    // MARK: - Variables
    
    /// Indicates if the object, HATProfileDataProfilePersonalObject, is private
    public var isPrivate: Bool = true {
        
        didSet {
            
            isPrivateTuple = (isPrivate, isPrivateTuple.1)
        }
    }
    
    /// User's first name
    public var firstName: String = "" {
        
        didSet {
            
            firstNameTuple = (firstName, firstNameTuple.1)
        }
    }
    /// User's last name
    public var lastName: String = "" {
        
        didSet {
            
            lastNameTuple = (lastName, lastNameTuple.1)
        }
    }
    /// User's middle name
    public var middleName: String = "" {
        
        didSet {
            
            middleNameTuple = (middleName, middleNameTuple.1)
        }
    }
    /// User's preffered name
    public var prefferedName: String = "" {
        
        didSet {
            
            prefferedNameTuple = (prefferedName, prefferedNameTuple.1)
        }
    }
    /// User's title
    public var title: String = "" {
        
        didSet {
            
            titleTuple = (title, titleTuple.1)
        }
    }
    
    /// A tuple containing the isPrivate and the ID of the value
    var isPrivateTuple: (Bool, Int) = (true, 0)
    
    /// A tuple containing the firstName and the ID of the value
    var firstNameTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the lastName and the ID of the value
    var lastNameTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the middleName and the ID of the value
    var middleNameTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the prefferedName and the ID of the value
    var prefferedNameTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the title and the ID of the value
    var titleTuple: (String, Int) = ("", 0)
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        isPrivate = true
        firstName = ""
        lastName = ""
        middleName = ""
        prefferedName = ""
        title = ""
        
        isPrivateTuple = (true, 0)
        firstNameTuple = ("", 0)
        lastNameTuple = ("", 0)
        middleNameTuple = ("", 0)
        prefferedNameTuple = ("", 0)
        titleTuple = ("", 0)
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
                        
                        if let stringResult = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            firstName = stringResult
                            firstNameTuple = (firstName, id)
                        }
                    }
                }
                
                if tempName == "last_name" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringResult = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            lastName = stringResult
                            lastNameTuple = (lastName, id)
                        }
                    }
                }
                
                if tempName == "preferred_name" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringResult = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            prefferedName = stringResult
                            prefferedNameTuple = (prefferedName, id)
                        }
                    }
                }
                
                if tempName == "middle_name" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringResult = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            middleName = stringResult
                            middleNameTuple = (middleName, id)
                        }
                    }
                }
                
                if tempName == "title" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringResult = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            title = stringResult
                            titleTuple = (title, id)
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
                
                if tempName == "private" {
                    
                    isPrivate = true
                    isPrivateTuple = (isPrivate, id)
                }
                
                if tempName == "first_name" {
                    
                    firstName = ""
                    firstNameTuple = (firstName, id)
                }
                
                if tempName == "last_name" {
                    
                    lastName = ""
                    lastNameTuple = (lastName, id)
                }
                
                if tempName == "preferred_name" {
                    
                    prefferedName = ""
                    prefferedNameTuple = (prefferedName, id)
                }
                
                if tempName == "middle_name" {
                    
                    middleName = ""
                    middleNameTuple = (middleName, id)
                }
                
                if tempName == "title" {
                    
                    title = ""
                    titleTuple = (title, id)
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
        
        if let tempPreferredName = (fromCache[Fields.preferredName]?.stringValue) {
            
            prefferedName = tempPreferredName
        }
        
        if let tempPreferredNameID = (fromCache[Fields.preferredNameID]?.intValue) {
            
            prefferedNameTuple = (prefferedName, tempPreferredNameID)
        }
        
        if let tempMiddleName = (fromCache[Fields.middleName]?.stringValue) {
            
            middleName = tempMiddleName
        }
        
        if let tempMiddleNameID = (fromCache[Fields.middleNameID]?.intValue) {
            
            middleNameTuple = (middleName, tempMiddleNameID)
        }
        
        if let tempTitle = (fromCache[Fields.title]?.stringValue) {
            
            title = tempTitle
        }
        
        if let tempTitleID = (fromCache[Fields.titleID]?.intValue) {
            
            titleTuple = (title, tempTitleID)
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
            Fields.preferredName: self.prefferedName,
            Fields.preferredNameID: self.prefferedNameTuple.1,
            Fields.middleName: self.middleName,
            Fields.middleNameID: self.middleNameTuple.1,
            Fields.title: self.title,
            Fields.titleID: self.titleTuple.1
        ]
    }
    
}
