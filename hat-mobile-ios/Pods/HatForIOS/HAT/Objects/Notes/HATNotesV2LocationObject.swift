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

public struct HATNotesV2LocationObject: HATObject, HatApiType {

    // MARK: - JSON Fields
    
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
    
    // MARK: - Variables
    
    /// the altitude the at time of creating the note. This value is optional
    public var altitude: Double?
    /// the altitude accuracy at the time of creating the note. This value is optional
    public var altitude_accuracy: Double?
    /// the latitude at the time of creating the note
    public var latitude: Double?
    /// the accuracy at the time of creating the note
    public var accuracy: Double?
    /// the longitude at the time of creating the note
    public var longitude: Double?
    /// the speed at the time of creating the note. This value is optional
    public var speed: Double?
    
    /// the heading at the time of creating the note. This value is optinal
    public var heading: String?
    
    /// is the location shared at the time of creating the note? This value is optional.
    public var shared: Bool?
    
    // MARK: - Initialiser
    
    public init() {
        
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        self.inititialize(dict: dict)
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public mutating func inititialize(dict: Dictionary<String, JSON>) {
        
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
                    
                    altitude_accuracy = doubleNumberAltitudeAccuracy
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
            
            Fields.altitude: self.altitude ?? 0,
            Fields.altitudeAccuracy: self.altitude_accuracy ?? 0,
            Fields.latitude: self.latitude ?? 0,
            Fields.heading: self.heading ?? 0,
            Fields.shared: String(describing: self.shared),
            Fields.accuracy: self.accuracy ?? 0,
            Fields.longitude: self.longitude ?? 0,
            Fields.speed: self.speed ?? 0
        ]
    }
}
