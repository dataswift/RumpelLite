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

public struct HATLocationsV2DataObject: HATObject, HatApiType {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let altitude: String = "altitude"
        static let latitude: String = "latitude"
        static let course: String = "course"
        static let horizontalAccuracy: String = "horizontalAccuracy"
        static let verticalAccuracy: String = "verticalAccuracy"
        static let longitude: String = "longitude"
        static let speed: String = "speed"
        static let dateCreated: String = "dateCreated"
        static let dateCreatedLocal: String = "dateCreatedLocal"
        static let floor: String = "floor"
    }
    
    public var latitude: Float = 0
    public var longitude: Float = 0
    public var dateCreated: Int = 0
    public var dateCreatedLocal: String = ""
    public var speed: Float?
    public var floor: Int?
    public var verticalAccuracy: Float?
    public var horizontalAccuracy: Float?
    public var altitude: Float?
    public var course: Float?
    
    public init() {
        
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dict: Dictionary<String, JSON>) {
        
        // check for values and assign them if not empty
        if let tempAltitude = dict[Fields.altitude]?.floatValue {
            
            altitude = tempAltitude
        }
        
        if let tempVerticalAccuracy = dict[Fields.verticalAccuracy]?.floatValue {
            
            verticalAccuracy = tempVerticalAccuracy
        }
        
        if let tempHorizontalAccuracy = dict[Fields.horizontalAccuracy]?.floatValue {
            
            horizontalAccuracy = tempHorizontalAccuracy
        }
        
        if let tempLatitude = dict[Fields.latitude]?.floatValue {
            
            latitude = tempLatitude
        }
        
        if let tempLongitude = dict[Fields.longitude]?.floatValue {
            
            longitude = tempLongitude
        }
        
        if let tempHeading = dict[Fields.course]?.floatValue {
            
            course = tempHeading
        }
        
        if let tempFloor = dict[Fields.floor]?.intValue {
            
            floor = tempFloor
        }
        
        if let tempSpeed = dict[Fields.speed]?.floatValue {
            
            speed = tempSpeed
        }
        
        if let tempDateCreated = dict[Fields.dateCreated]?.intValue {
            
            dateCreated = tempDateCreated
        }
        
        if let tempDateCreatedLocal = dict[Fields.dateCreatedLocal]?.stringValue {
            
            dateCreatedLocal = tempDateCreatedLocal
        }
    }
    
    public func initialize(fromCache: Dictionary<String, Any>) {
        
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.altitude: self.altitude ?? 0,
            Fields.verticalAccuracy: self.verticalAccuracy ?? 0,
            Fields.horizontalAccuracy: self.horizontalAccuracy ?? 0,
            Fields.latitude: self.latitude,
            Fields.course: self.course ?? 0,
            Fields.floor: self.floor ?? 0,
            Fields.dateCreated: self.dateCreated,
            Fields.dateCreatedLocal: self.dateCreatedLocal,
            Fields.longitude: self.longitude,
            Fields.speed: self.speed ?? 0
        ]
    }
}
