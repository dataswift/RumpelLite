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

/// A class representing the locations actual data
public struct HATLocationsDataLocationsObject: Equatable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let latitude: String = "latitude"
        static let longitude: String = "longitude"
        static let accuracy: String = "accuracy"
        static let timestamp: String = "timestamp"
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
    public static func == (lhs: HATLocationsDataLocationsObject, rhs: HATLocationsDataLocationsObject) -> Bool {

        return (lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude && lhs.accuracy == rhs.accuracy && lhs.timeStamp == rhs.timeStamp)
    }

    // MARK: - Variables

    /// The latitude of the location
    public var latitude: String = ""
    /// The longitude of the location
    public var longitude: String = ""
    /// The accuracy of the location
    public var accuracy: String = ""
    /// The date of the location
    public var timeStamp: Date?

    // MARK: - Initialisers

    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {

        latitude = ""
        longitude = ""
        accuracy = ""
        timeStamp = nil
    }

    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dict: Dictionary<String, JSON>) {

        self.init()

        // this field will always have a value no need to use if let
        if let tempLatitude = dict[Fields.latitude]?.stringValue {

            latitude = tempLatitude
        }

        if let tempLongitude = dict[Fields.longitude]?.stringValue {

            longitude = tempLongitude
        }

        if let tempAccuracy = dict[Fields.accuracy]?.stringValue {

            accuracy = tempAccuracy
        }

        if let tempTimeStamp = dict[Fields.timestamp]?.stringValue {

            timeStamp = HATFormatterHelper.formatStringToDate(string: tempTimeStamp)
        }
    }

    // MARK: - JSON Mapper

    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {

        return [

            Fields.latitude: self.latitude,
            Fields.longitude: self.longitude,
            Fields.accuracy: self.accuracy,
            Fields.timestamp: Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!
        ]
    }
}
