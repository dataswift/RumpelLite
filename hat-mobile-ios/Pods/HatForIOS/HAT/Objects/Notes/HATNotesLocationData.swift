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

/// A struct representing the location table received from JSON
public struct HATNotesLocationData: Comparable {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let altitude: String = "altitude"
        static let altitudeAccuracy: String = "altitude_accuracy"
        static let latitude: String = "latitude"
        static let heading: String = "heading"
        static let shared: String = "shared"
        static let accuracy: String = "accuracy"
        static let longitude: String = "longitude"
        static let speed: String = "speed"
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
    public static func == (lhs: HATNotesLocationData, rhs: HATNotesLocationData) -> Bool {

        return (lhs.altitude == rhs.altitude && lhs.altitudeAccuracy == rhs.altitudeAccuracy && lhs.latitude == rhs.latitude
            && lhs.accuracy == rhs.accuracy && lhs.longitude == rhs.longitude && lhs.speed == rhs.speed && lhs.heading == rhs.heading && lhs.shared == rhs.shared)
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
    public static func < (lhs: HATNotesLocationData, rhs: HATNotesLocationData) -> Bool {

        if lhs.latitude != nil && lhs.longitude != nil && rhs.latitude != nil && rhs.longitude != nil {

            return (lhs.latitude! < rhs.latitude! && lhs.longitude! < rhs.longitude!)
        }

        return false
    }

    // MARK: - Variables

    /// the altitude the at time of creating the note. This value is optional
    public var altitude: Double = 0
    /// the altitude accuracy at the time of creating the note. This value is optional
    public var altitudeAccuracy: Double = 0
    /// the latitude at the time of creating the note
    public var latitude: Double?
    /// the accuracy at the time of creating the note
    public var accuracy: Double = 0
    /// the longitude at the time of creating the note
    public var longitude: Double?
    /// the speed at the time of creating the note. This value is optional
    public var speed: Double = 0

    /// the heading at the time of creating the note. This value is optinal
    public var heading: String  = ""

    /// is the location shared at the time of creating the note? This value is optional.
    public var shared: Bool = false

    // MARK: Initialisers

    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {

        altitude = 0
        altitudeAccuracy = 0
        latitude = nil
        heading = ""
        shared = false
        accuracy = 0
        longitude = nil
        speed = 0
    }

    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dict: Dictionary<String, JSON>) {

        // check for values and assign them if not empty
        if let tempAltitude = dict[Fields.altitude]?.string {

            if tempAltitude != "" {

                if let doubleNumberAltitute = Double(tempAltitude) {

                    altitude = doubleNumberAltitute
                }
            }
        }

        if let tempAltitudeAccuracy = dict[Fields.altitudeAccuracy]?.string {

            if tempAltitudeAccuracy != "" {

                if let doubleNumberAltitudeAccuracy = Double(tempAltitudeAccuracy) {

                    altitudeAccuracy = doubleNumberAltitudeAccuracy
                }
            }
        }

        if let tempLatitude = dict[Fields.latitude]?.string {

            if tempLatitude != "" {

                if let doubleNumberLatitude = Double(tempLatitude) {

                    latitude = doubleNumberLatitude
                }
            }
        }
        if let tempHeading = dict[Fields.heading]?.string {

            heading = tempHeading
        }

        if let tempShared = dict[Fields.shared]?.string {

            if tempShared != "" {

                if let boolShared = Bool(tempShared) {

                    shared = boolShared
                }
            }
        }
        if let tempAccuracy = dict[Fields.accuracy]?.string {

            if tempAccuracy != "" {

                if let doubleNumberAccuracy = Double(tempAccuracy) {

                    accuracy = doubleNumberAccuracy
                }
            }
        }
        if let tempLongitude = dict[Fields.longitude]?.string {

            if tempLongitude != "" {

                if let doubleNumberLongitude = Double(tempLongitude) {

                    longitude = doubleNumberLongitude
                }
            }
        }
        if let tempSpeed = dict[Fields.speed]?.string {

            if tempSpeed != "" {

                if let doubleNumberSpeed = Double(tempSpeed) {

                    speed = doubleNumberSpeed
                }
            }
        }
    }

    // MARK: - JSON Mapper

    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {

        return [

            Fields.altitude: self.altitude,
            Fields.altitudeAccuracy: self.altitudeAccuracy,
            Fields.latitude: self.latitude ?? 0,
            Fields.heading: self.heading,
            Fields.shared: String(describing: self.shared),
            Fields.accuracy: self.accuracy,
            Fields.longitude: self.longitude ?? 0,
            Fields.speed: self.speed
        ]
    }
}
