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

/// A struct representing the profile data Address Detail object from the received profile JSON file
public struct HATProfileDataProfileAddressDetailObject: Comparable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    struct Fields {
        
        static let isPrivate: String = "private"
        static let isPrivateID: String = "privateID"
        static let number: String = "no"
        static let numberID: String = "numberID"
        static let street: String = "street"
        static let streetID: String = "streetID"
        static let postcode: String = "postcode"
        static let postcodeID: String = "postcodeID"
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
    public static func == (lhs: HATProfileDataProfileAddressDetailObject, rhs: HATProfileDataProfileAddressDetailObject) -> Bool {
        
        return (lhs.isPrivate == rhs.isPrivate && lhs.number == rhs.number && lhs.street == rhs.street && lhs.postCode == rhs.postCode)
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
    public static func < (lhs: HATProfileDataProfileAddressDetailObject, rhs: HATProfileDataProfileAddressDetailObject) -> Bool {
        
        return lhs.street < rhs.street
    }
    
    // MARK: - Variables
    
    /// Indicates if the object, HATProfileDataProfileAddressDetailObject, is private
    public var isPrivate: Bool = true {
        
        didSet {
            
            isPrivateTuple = (isPrivate, isPrivateTuple.1)
        }
    }
    
    /// User's street address number
    public var number: String = "" {
        
        didSet {
            
            numberTuple = (number, numberTuple.1)
        }
    }
    /// User's street name
    public var street: String = "" {
        
        didSet {
            
            streetTuple = (street, streetTuple.1)
        }
    }
    /// User's post code
    public var postCode: String = "" {
        
        didSet {
            
            postCodeTuple = (postCode, postCodeTuple.1)
        }
    }
    
    /// A tuple containing the isPrivate and the ID of the value
    var isPrivateTuple: (Bool, Int) = (true, 0)
    
    /// A tuple containing the value and the ID of the value
    var numberTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the value and the ID of the value
    var streetTuple: (String, Int) = ("", 0)
    
    /// A tuple containing the value and the ID of the value
    var postCodeTuple: (String, Int) = ("", 0)
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        isPrivate = true
        number = ""
        street = ""
        postCode = ""
        
        isPrivateTuple = (true, 0)
        numberTuple = ("", 0)
        streetTuple = ("", 0)
        postCodeTuple = ("", 0)
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
                
                if tempName == "no" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            number = stringValue
                            numberTuple = (number, id)
                        }
                    }
                }
                
                if tempName == "street" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            street = stringValue
                            streetTuple = (street, id)
                        }
                    }
                }
                
                if tempName == "postcode" {
                    
                    if let tempValues = dict[Fields.values]?.arrayValue {
                        
                        if let stringValue = tempValues[0].dictionaryValue[Fields.value]?.stringValue {
                            
                            postCode = stringValue
                            postCodeTuple = (postCode, id)
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
                
                if tempName == "no" {
                    
                    number = ""
                    numberTuple = (number, id)
                }
                
                if tempName == "street" {
                    
                    street = ""
                    streetTuple = (street, id)
                }
                
                if tempName == "postcode" {
                    
                    postCode = ""
                    postCodeTuple = (postCode, id)
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
        
        if let tempNumber = (fromCache[Fields.number]?.stringValue) {
            
            number = tempNumber
        }
        
        if let tempNumberID = (fromCache[Fields.numberID]?.intValue) {
            
            numberTuple = (number, tempNumberID)
        }
        
        if let tempStreet = (fromCache[Fields.street]?.stringValue) {
            
            street = tempStreet
        }
        
        if let tempStreetID = (fromCache[Fields.streetID]?.intValue) {
            
            streetTuple = (street, tempStreetID)
        }
        
        if let tempPostcode = (fromCache[Fields.postcode]?.stringValue) {
            
            postCode = tempPostcode
        }
        
        if let tempPostcodeID = (fromCache[Fields.postcodeID]?.intValue) {
            
            postCodeTuple = (postCode, tempPostcodeID)
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
            Fields.isPrivateID: isPrivateTuple.1,
            Fields.number: self.number,
            Fields.numberID: numberTuple.1,
            Fields.street: self.street,
            Fields.streetID: streetTuple.1,
            Fields.postcode: self.postCode,
            Fields.postcodeID: postCodeTuple.1
        ]
    }
    
}
