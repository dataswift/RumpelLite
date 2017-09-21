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

/// A struct representing the notables table received from JSON
public struct HATNotesNotablesData: Comparable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let authorArray: String = "authorv1"
        static let photoArray: String = "photov1"
        static let locationArray: String = "locationv1"
        static let sharedOn: String = "shared_on"
        static let publicUntil: String = "public_until"
        static let createdTime: String = "created_time"
        static let updatedTime: String = "updated_time"
        static let shared: String = "shared"
        static let message: String = "message"
        static let kind: String = "kind"
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
    public static func == (lhs: HATNotesNotablesData, rhs: HATNotesNotablesData) -> Bool {
        
        return (lhs.authorData == rhs.authorData && lhs.photoData == rhs.photoData && lhs.locationData == rhs.locationData
            && lhs.createdTime == rhs.createdTime && lhs.publicUntil == rhs.publicUntil && lhs.updatedTime == rhs.updatedTime && lhs.shared == rhs.shared && lhs.sharedOn == rhs.sharedOn && lhs.message == rhs.message && lhs.kind == rhs.kind)
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
    public static func < (lhs: HATNotesNotablesData, rhs: HATNotesNotablesData) -> Bool {
        
        return lhs.updatedTime < rhs.updatedTime
    }
    
    // MARK: - Variables
    
    /// the author data
    public var authorData: HATNotesAuthorData = HATNotesAuthorData()
    
    /// the photo data
    public var photoData: HATNotesPhotoData = HATNotesPhotoData()
    
    /// the location data
    public var locationData: HATNotesLocationData = HATNotesLocationData()
    
    /// creation date
    public var createdTime: Date = Date()
    /// the date until this note will be public (don't know if it's optional or not)
    public var publicUntil: Date?
    /// the updated time of the note
    public var updatedTime: Date = Date()
    
    /// if true this note is shared to facebook etc.
    public var shared: Bool = false
    
    /// If shared, where is it shared? Coma seperated string (don't know if it's optional or not)
    public var sharedOn: String = ""
    /// the actual message of the note
    public var message: String = ""
    /// the kind of the note. 3 types available note, blog or list
    public var kind: String = ""
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        authorData = HATNotesAuthorData.init()
        createdTime = Date()
        shared = false
        sharedOn = ""
        photoData = HATNotesPhotoData.init()
        locationData = HATNotesLocationData.init()
        message = ""
        publicUntil = nil
        updatedTime = Date()
        kind = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dict: Dictionary<String, JSON>) {
        
        if let tempAuthorData = dict[Fields.authorArray]?.dictionary {
            
            authorData = HATNotesAuthorData.init(dict: tempAuthorData)
        }
        
        if let tempPhotoData = dict[Fields.photoArray]?.dictionary {
            
            photoData = HATNotesPhotoData.init(dict: tempPhotoData)
        }
        
        if let tempLocationData = dict[Fields.locationArray]?.dictionary {
            
            locationData = HATNotesLocationData.init(dict: tempLocationData)
        }
        
        if let tempSharedOn = dict[Fields.sharedOn]?.string {
            
            sharedOn = tempSharedOn
        }
        
        if let tempPublicUntil = dict[Fields.publicUntil]?.string {
            
            publicUntil = HATFormatterHelper.formatStringToDate(string: tempPublicUntil)
        }
        
        if let tempCreatedTime = dict[Fields.createdTime]?.string {
            
            if let returnedDate = HATFormatterHelper.formatStringToDate(string: tempCreatedTime) {
                
                createdTime = returnedDate
            }
        }
        
        if let tempUpdatedTime = dict[Fields.updatedTime]?.string {
            
            if let returnedDate = HATFormatterHelper.formatStringToDate(string: tempUpdatedTime) {
                
                updatedTime = returnedDate
            }
        }
        
        if let tempDict = dict[Fields.shared]?.string {
            
            if tempDict == "" {
                
                shared = false
            } else {
                
                if let boolShared = Bool(tempDict) {
                    
                    shared = boolShared
                }
            }
        }
        
        if let tempMessage = dict[Fields.message]?.string {
            
            message = tempMessage
        }
        
        if let tempKind = dict[Fields.kind]?.string {
            
            kind = tempKind
        }
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        var tempPublicUntil = 0
        if self.publicUntil == nil {
            
            tempPublicUntil = Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!
        } else {
            
            tempPublicUntil = Int(HATFormatterHelper.formatDateToEpoch(date: self.publicUntil!)!)!
        }
        
        return [
            
            Fields.authorArray: self.authorData.toJSON(),
            Fields.photoArray: self.photoData.toJSON(),
            Fields.locationArray: self.locationData.toJSON(),
            Fields.sharedOn: self.sharedOn,
            Fields.publicUntil: tempPublicUntil,
            Fields.createdTime: HATFormatterHelper.formatDateToISO(date: self.createdTime),
            Fields.updatedTime: HATFormatterHelper.formatDateToISO(date: self.updatedTime),
            Fields.shared: String(describing: self.shared),
            Fields.message: self.message,
            Fields.kind: self.kind
        ]
    }
}
