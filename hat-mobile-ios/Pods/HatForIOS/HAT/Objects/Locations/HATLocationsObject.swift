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

/// A class representing the locations received from server
public struct HATLocationsObject: Equatable, HatApiType {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let locationID: String = "id"
        static let recordID: String = "recordId"
        static let endPoint: String = "endpoint"
        static let lastUpdated: String = "lastUpdated"
        static let locations: String = "locations"
        static let data: String = "data"
        static let name: String = "name"
        static let unixTimeStamp: String = "unixTimeStamp"
    }

    // MARK: - Equatable protocol

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HATLocationsObject, rhs: HATLocationsObject) -> Bool {

        return (lhs.locationID == rhs.locationID && lhs.lastUpdate == rhs.lastUpdate && lhs.name == rhs.name && lhs.data == rhs.data)
    }

    // MARK: - Variables

    /// The id of the location record
    public var locationID: Int = 0
    /// The last updated date of the record
    public var lastUpdate: Date?
    /// The name of the record
    public var name: String = ""
    /// The data of the location object
    public var data: HATLocationsDataObject = HATLocationsDataObject()
    /// The endPoint of the note, used in v2 API only
    public var endPoint: String = ""

    /// The recordID of the note, used in v2 API only
    public var recordID: String = ""

    // MARK: - Initialisers

    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {

        locationID = 0
        lastUpdate = nil
        name = ""
        data = HATLocationsDataObject()
        endPoint = ""
        recordID = ""
    }

    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dict: Dictionary<String, JSON>) {

        // init optional JSON fields to default values
        self.init()

        self.initialize(from: dict)
    }
    
    /**
     It initialises everything from the received JSON file from the cache
     */
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let dictionary = JSON(fromCache)
        self.initialize(from: dictionary.dictionaryValue)
    }
    
    /**
     It initialises everything from the received JSON file from the cache
     */
    public mutating func initialize(from dictionary: Dictionary<String, JSON>) {
        
        // this field will always have a value no need to use if let
        if let tempID = dictionary[Fields.locationID]?.intValue {
            
            locationID = tempID
        }
        
        if let tempUpdatedTime = dictionary[Fields.lastUpdated]?.string {
            
            lastUpdate = HATFormatterHelper.formatStringToDate(string: tempUpdatedTime)
        }
        
        if let tempName = dictionary[Fields.name]?.string {
            
            name = tempName
        }
        
        if let tempTables = dictionary[Fields.data]?.dictionaryValue {
            
            data = HATLocationsDataObject(dict: tempTables)
        }
        
        if dictionary[Fields.locations]?.dictionaryValue != nil {
            
            data = HATLocationsDataObject(dict: dictionary)
        }
    }

    /**
     It initialises everything from the received JSON file from the HAT using V2 API
     */
    public init(dictV2: Dictionary<String, JSON>) {

        // init optional JSON fields to default values
        self.init()

        if let tempEndpoint = dictV2[Fields.endPoint]?.string {

            endPoint = tempEndpoint
        }

        if let tempRecordID = dictV2[Fields.recordID]?.string {

            recordID = tempRecordID
        }

        if let tempTables = dictV2[Fields.data]?.dictionaryValue {

            if let tempUpdatedTime = tempTables[Fields.lastUpdated]?.string {

                lastUpdate = HATFormatterHelper.formatStringToDate(string: tempUpdatedTime)
            }

            data = HATLocationsDataObject(dict: tempTables)
        }
    }

    // MARK: - JSON Mapper

    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {

        return [

            Fields.locations: self.data.locations.toJSON(),
            Fields.unixTimeStamp: Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!
        ]
    }
}
