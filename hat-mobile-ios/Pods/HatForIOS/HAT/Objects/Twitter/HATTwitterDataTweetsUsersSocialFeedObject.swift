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

/// A class representing the user's info of a tweet
public struct HATTwitterDataTweetsUsersSocialFeedObject: HatApiType, Comparable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let friendsCount: String = "friends_count"
        static let userID: String = "id"
        static let language: String = "lang"
        static let favoritesCount: String = "favorites_count"
        static let statusesCount: String = "statuses_count"
        static let listedCount: String = "listed_count"
        static let screenName: String = "screen_name"
        static let name: String = "name"
        static let followersCount: String = "followers_count"
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
    public static func == (lhs: HATTwitterDataTweetsUsersSocialFeedObject, rhs: HATTwitterDataTweetsUsersSocialFeedObject) -> Bool {

        return (lhs.friendsCount == rhs.friendsCount && lhs.userID == rhs.userID && lhs.lang == rhs.lang && lhs.listedCount == rhs.listedCount && lhs.favouritesCount == rhs.favouritesCount && lhs.statusesCount == rhs.statusesCount && lhs.screenName == rhs.screenName && lhs.name == rhs.name && lhs.followersCount == rhs.followersCount)
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
    public static func < (lhs: HATTwitterDataTweetsUsersSocialFeedObject, rhs: HATTwitterDataTweetsUsersSocialFeedObject) -> Bool {

        return lhs.name < rhs.name
    }

    // MARK: - Variables

    /// The user's friend count
    public var friendsCount: String = ""
    /// The user's id
    public var userID: String = ""
    /// The user's language
    public var lang: String = ""
    /// The user's listed count
    public var listedCount: String = ""
    /// The user's favourites count
    public var favouritesCount: String = ""
    /// The user's statuses count
    public var statusesCount: String = ""
    /// The user's screen name
    public var screenName: String = ""
    /// The user's name
    public var name: String = ""
    /// The user's followers count
    public var followersCount: String = ""

    // MARK: - Initialisers

    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {

        friendsCount = ""
        userID = ""
        lang = ""
        listedCount = ""
        favouritesCount = ""
        statusesCount = ""
        screenName = ""
        name = ""
        followersCount = ""
    }

    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dictionary: Dictionary<String, JSON>) {

        self.init()

        if let tempFriendsCount = dictionary[Fields.friendsCount]?.stringValue {

            friendsCount = tempFriendsCount
        }
        if let tempID = dictionary[Fields.userID]?.stringValue {

            userID = tempID
        }
        if let tempLang = dictionary[Fields.language]?.stringValue {

            lang = tempLang
        }
        if let tempListedCount = dictionary[Fields.listedCount]?.stringValue {

            listedCount = tempListedCount
        }
        if let tempFavouritesCount = dictionary[Fields.favoritesCount]?.stringValue {

            favouritesCount = tempFavouritesCount
        }
        if let tempStatusesCount = dictionary[Fields.statusesCount]?.stringValue {

            statusesCount = tempStatusesCount
        }
        if let tempScreenName = dictionary[Fields.screenName]?.stringValue {

            screenName = tempScreenName
        }
        if let tempName = dictionary[Fields.name]?.stringValue {

            name = tempName
        }
        if let tempFollowersCount = dictionary[Fields.followersCount]?.stringValue {

            followersCount = tempFollowersCount
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public mutating func inititialize(dict: Dictionary<String, JSON>) {
        
        if let tempFriendsCount = dict[Fields.friendsCount]?.stringValue {
            
            friendsCount = tempFriendsCount
        }
        if let tempID = dict[Fields.userID]?.stringValue {
            
            userID = tempID
        }
        if let tempLang = dict[Fields.language]?.stringValue {
            
            lang = tempLang
        }
        if let tempListedCount = dict[Fields.listedCount]?.stringValue {
            
            listedCount = tempListedCount
        }
        if let tempFavouritesCount = dict[Fields.favoritesCount]?.stringValue {
            
            favouritesCount = tempFavouritesCount
        }
        if let tempStatusesCount = dict[Fields.statusesCount]?.stringValue {
            
            statusesCount = tempStatusesCount
        }
        if let tempScreenName = dict[Fields.screenName]?.stringValue {
            
            screenName = tempScreenName
        }
        if let tempName = dict[Fields.name]?.stringValue {
            
            name = tempName
        }
        if let tempFollowersCount = dict[Fields.followersCount]?.stringValue {
            
            followersCount = tempFollowersCount
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
            
            Fields.friendsCount: self.friendsCount,
            Fields.userID: self.userID,
            Fields.language: self.lang,
            Fields.favoritesCount: self.favouritesCount,
            Fields.statusesCount: self.statusesCount,
            Fields.listedCount: self.listedCount,
            Fields.screenName: self.screenName,
            Fields.name: self.name,
            Fields.followersCount: self.followersCount
        ]
    }
}
