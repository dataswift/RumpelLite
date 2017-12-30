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

/// A class representing the actual data of the post
public struct HATFacebookDataPostsSocialFeedObject: HatApiType, Comparable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let from: String = "from"
        static let postID: String = "id"
        static let statusType: String = "status_type"
        static let privacy: String = "privacy"
        static let updatedTime: String = "updated_time"
        static let type: String = "type"
        static let createdTime: String = "created_time"
        static let message: String = "message"
        static let fullPicture: String = "full_picture"
        static let link: String = "link"
        static let picture: String = "picture"
        static let story: String = "story"
        static let description: String = "description"
        static let objectID: String = "object_id"
        static let application: String = "application"
        static let caption: String = "caption"
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
    public static func == (lhs: HATFacebookDataPostsSocialFeedObject, rhs: HATFacebookDataPostsSocialFeedObject) -> Bool {
        
        return (lhs.from == rhs.from && lhs.privacy == rhs.privacy && lhs.updatedTime == rhs.updatedTime && lhs.createdTime == rhs.createdTime && lhs.postID == rhs.postID && lhs.message == rhs.message && lhs.statusType == rhs.statusType && lhs.type == rhs.type && lhs.fullPicture == rhs.fullPicture && lhs.link == rhs.link && lhs.picture == rhs.picture && lhs.story == rhs.story && lhs.name == rhs.name && lhs.description == rhs.description && lhs.objectID == rhs.objectID && lhs.caption == rhs.caption && lhs.application == rhs.application)
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
    public static func < (lhs: HATFacebookDataPostsSocialFeedObject, rhs: HATFacebookDataPostsSocialFeedObject) -> Bool {
        
        if lhs.updatedTime != nil && rhs.updatedTime != nil {
            
            return lhs.updatedTime! < rhs.updatedTime!
        } else if lhs.updatedTime != nil && rhs.updatedTime == nil {
            
            return false
        } else {
            
            return true
        }
    }
    
    // MARK: - Variables
    
    /// The user that made the post
    public var from: HATFacebookDataPostsFromSocialFeedObject = HATFacebookDataPostsFromSocialFeedObject()
    
    /// The privacy settings for the post
    public var privacy: HATFacebookDataPostsPrivacySocialFeedObject = HATFacebookDataPostsPrivacySocialFeedObject()
    
    /// The updated time of the post
    public var updatedTime: Date?
    /// The created time of the post
    public var createdTime: Date?
    
    /// The message of the post
    public var message: String = ""
    /// The id of the post
    public var postID: String = ""
    /// The status type of the post
    public var statusType: String = ""
    /// The type of the post, status, video, image, etc,
    public var type: String = ""
    
    /// The full picture url
    public var fullPicture: String = ""
    /// If the post has a link to somewhere has the url
    public var link: String = ""
    /// The picture url
    public var picture: String = ""
    /// The story of the post
    public var story: String = ""
    /// The name of the post
    public var name: String = ""
    /// The description of the post
    public var description: String = ""
    /// The object id of the post
    public var objectID: String = ""
    /// The caption of the post
    public var caption: String = ""
    
    /// The application details of the post
    public var application: HATFacebookDataPostsApplicationSocialFeedObject = HATFacebookDataPostsApplicationSocialFeedObject()
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        from = HATFacebookDataPostsFromSocialFeedObject()
        postID = ""
        statusType = ""
        privacy = HATFacebookDataPostsPrivacySocialFeedObject()
        updatedTime = nil
        type = ""
        createdTime = nil
        message = ""
        
        fullPicture = ""
        link = ""
        picture = ""
        story = ""
        name = ""
        description = ""
        objectID = ""
        application = HATFacebookDataPostsApplicationSocialFeedObject()
        caption = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        self.inititialize(dict: dictionary)
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public mutating func inititialize(dict: Dictionary<String, JSON>) {
        
        if let tempFrom = dict[Fields.from]?.dictionaryValue {
            
            from = HATFacebookDataPostsFromSocialFeedObject(from: tempFrom)
        }
        if let tempID = dict[Fields.postID]?.stringValue {
            
            postID = tempID
        }
        if let tempStatusType = dict[Fields.statusType]?.stringValue {
            
            statusType = tempStatusType
        }
        if let tempPrivacy = dict[Fields.privacy]?.dictionaryValue {
            
            privacy = HATFacebookDataPostsPrivacySocialFeedObject(from: tempPrivacy)
        }
        if let tempUpdateTime = dict[Fields.updatedTime]?.stringValue {
            
            updatedTime = HATFormatterHelper.formatStringToDate(string: tempUpdateTime)
        }
        if let tempType = dict[Fields.type]?.stringValue {
            
            type = tempType
        }
        if let tempCreatedTime = dict[Fields.createdTime]?.stringValue {
            
            createdTime = HATFormatterHelper.formatStringToDate(string: tempCreatedTime)
        }
        if let tempMessage = dict[Fields.message]?.stringValue {
            
            message = tempMessage
        }
        if let tempFullPicture = dict[Fields.fullPicture]?.stringValue {
            
            fullPicture = tempFullPicture
        }
        if let tempLink = dict[Fields.link]?.stringValue {
            
            link = tempLink
        }
        if let tempPicture = dict[Fields.picture]?.stringValue {
            
            picture = tempPicture
        }
        if let tempStory = dict[Fields.story]?.stringValue {
            
            story = tempStory
        }
        if let tempDescription = dict[Fields.description]?.stringValue {
            
            description = tempDescription
        }
        if let tempObjectID = dict[Fields.objectID]?.stringValue {
            
            objectID = tempObjectID
        }
        if let tempApplication = dict[Fields.application]?.dictionaryValue {
            
            application = HATFacebookDataPostsApplicationSocialFeedObject(from: tempApplication)
        }
        if let tempCaption = dict[Fields.caption]?.stringValue {
            
            caption = tempCaption
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
            
            Fields.from: self.from.toJSON(),
            Fields.postID: self.postID,
            Fields.statusType: self.statusType,
            Fields.privacy: self.privacy.toJSON(),
            Fields.updatedTime: HATFormatterHelper.formatDateToISO(date: self.updatedTime ?? Date()),
            Fields.type: self.type,
            Fields.createdTime: HATFormatterHelper.formatDateToISO(date: self.createdTime ?? Date()),
            Fields.message: self.message,
            Fields.fullPicture: self.fullPicture,
            Fields.link: self.link,
            Fields.picture: self.picture,
            Fields.story: self.story,
            Fields.description: self.description,
            Fields.objectID: self.objectID,
            Fields.application: self.application.toJSON(),
            Fields.caption: self.caption
        ]
    }
}
