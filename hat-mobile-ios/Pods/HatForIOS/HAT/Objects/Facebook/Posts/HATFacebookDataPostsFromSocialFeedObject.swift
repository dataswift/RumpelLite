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

// MARK: Class

/// A class representing the user's details that made the post
public struct HATFacebookDataPostsFromSocialFeedObject: HatApiType, Comparable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let dataPostID: String = "id"
        static let name: String = "name"
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
    public static func == (lhs: HATFacebookDataPostsFromSocialFeedObject, rhs: HATFacebookDataPostsFromSocialFeedObject) -> Bool {

        return (lhs.name == rhs.name && lhs.userID == rhs.userID)
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
    public static func < (lhs: HATFacebookDataPostsFromSocialFeedObject, rhs: HATFacebookDataPostsFromSocialFeedObject) -> Bool {

        return lhs.name < rhs.name
    }

    // MARK: - Variables

    /// The user's name
    public var name: String = ""
    /// The user's id
    public var userID: String = ""

    // MARK: - Initialisers

    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {

        name = ""
        userID = ""
    }

    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dictionary: Dictionary<String, JSON>) {

        self.init()

        if let tempName = dictionary[Fields.name]?.stringValue {

            name = tempName
        }
        if let tempID = dictionary[Fields.dataPostID]?.stringValue {

            userID = tempID
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public mutating func inititialize(dict: Dictionary<String, JSON>) {
        
        if let tempName = dict[Fields.name]?.stringValue {
            
            name = tempName
        }
        if let tempID = dict[Fields.dataPostID]?.stringValue {
            
            userID = tempID
        }
    }
    
    /**
     It initialises everything from the received JSON file from the cache
     */
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let dictionary = JSON(fromCache)
        self.inititialize(dict: dictionary.dictionaryValue)
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.name: self.name,
            Fields.dataPostID: self.userID
        ]
    }
}
