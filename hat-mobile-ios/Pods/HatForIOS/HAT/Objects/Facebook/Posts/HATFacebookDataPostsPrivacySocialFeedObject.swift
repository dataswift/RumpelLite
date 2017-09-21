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

/// A class representing the privacy settings of the post
public struct HATFacebookDataPostsPrivacySocialFeedObject: HatApiType, Comparable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let friends: String = "friends"
        static let value: String = "value"
        static let deny: String = "deny"
        static let description: String = "description"
        static let allow: String = "allow"
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
    public static func == (lhs: HATFacebookDataPostsPrivacySocialFeedObject, rhs: HATFacebookDataPostsPrivacySocialFeedObject) -> Bool {

        return (lhs.friends == rhs.friends && lhs.value == rhs.value && lhs.deny == rhs.deny && lhs.description == rhs.description && lhs.allow == rhs.allow)
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
    public static func < (lhs: HATFacebookDataPostsPrivacySocialFeedObject, rhs: HATFacebookDataPostsPrivacySocialFeedObject) -> Bool {

        return lhs.description < rhs.description
    }

    // MARK: - Variables

    /// Is it friends only?
    public var friends: String = ""
    /// The value
    public var value: String = ""
    /// deny access?
    public var deny: String = ""
    /// The desctiption of the setting
    public var description: String = ""
    /// Allow?
    public var allow: String = ""

    // MARK: - Initialisers

    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {

        friends = ""
        value = ""
        deny = ""
        description = ""
        allow = ""
    }

    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dictionary: Dictionary<String, JSON>) {

        self.init()

        if let tempFriends = dictionary[Fields.friends]?.stringValue {

            friends = tempFriends
        }
        if let tempValue = dictionary[Fields.value]?.stringValue {

            value = tempValue
        }
        if let tempDeny = dictionary[Fields.deny]?.string {

            deny = tempDeny
        }
        if let tempDescription = dictionary[Fields.description]?.stringValue {

            description = tempDescription
        }
        if let tempAllow = dictionary[Fields.allow]?.stringValue {

            allow = tempAllow
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public mutating func inititialize(dict: Dictionary<String, JSON>) {
        
        if let tempFriends = dict[Fields.friends]?.stringValue {
            
            friends = tempFriends
        }
        if let tempValue = dict[Fields.value]?.stringValue {
            
            value = tempValue
        }
        if let tempDeny = dict[Fields.deny]?.string {
            
            deny = tempDeny
        }
        if let tempDescription = dict[Fields.description]?.stringValue {
            
            description = tempDescription
        }
        if let tempAllow = dict[Fields.allow]?.stringValue {
            
            allow = tempAllow
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
            
            Fields.friends: self.friends,
            Fields.deny: self.deny,
            Fields.value: self.value,
            Fields.description: self.description,
            Fields.allow: self.allow
        ]
    }
}
