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

public struct HATFacebookProfileImageObject: HatApiType {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let recordID: String = "recordId"
        static let data: String = "data"
        static let isSilhouette: String = "is_silhouette"
        static let height: String = "height"
        static let width: String = "width"
        static let url: String = "url"
        static let endPoint: String = "endpoint"
        static let lastUpdated: String = "lastUpdated"
    }

    // MARK: - Variables

    var isSilhouette: Bool = false
    var url: String = ""
    var imageHeight: Int = 0
    var imageWidth: Int = 0
    var lastUpdated: Int?
    var recordID: String?
    var endPoint: String = "profile_picture"

    // MARK: - Initialisers

    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {

        isSilhouette = false
        url = ""
        imageWidth = 0
        imageHeight = 0
        lastUpdated = nil
        recordID = nil
        endPoint = "profile_picture"
    }

    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dictionary: Dictionary<String, JSON>) {

        self.init()

        if let tempRecordID = dictionary[Fields.recordID]?.stringValue {

            recordID = tempRecordID
        }

        if let tempEndPoint = dictionary[Fields.endPoint]?.stringValue {

            endPoint = tempEndPoint
        }

        if let data = dictionary[Fields.data]?.dictionaryValue {

            // In new v2 API last updated will be inside data
            if let tempLastUpdated = data[Fields.lastUpdated]?.stringValue {

                if let date = HATFormatterHelper.formatStringToDate(string: tempLastUpdated) {

                    lastUpdated = Int(HATFormatterHelper.formatDateToEpoch(date: date)!)
                }
            }
            if let tempSilhouette = dictionary[Fields.isSilhouette]?.boolValue {

                isSilhouette = tempSilhouette
            }
            if let tempHeight = dictionary[Fields.height]?.string {

                imageHeight = Int(tempHeight)!
            }
            if let tempWidth = dictionary[Fields.width]?.stringValue {

                imageWidth = Int(tempWidth)!
            }
            if let tempLink = dictionary[Fields.url]?.stringValue {

                url = tempLink
            }
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public mutating func inititialize(dict: Dictionary<String, JSON>) {
        
        if let tempRecordID = dict[Fields.recordID]?.stringValue {
            
            recordID = tempRecordID
        }
        
        if let tempEndPoint = dict[Fields.endPoint]?.stringValue {
            
            endPoint = tempEndPoint
        }
        
        if let data = dict[Fields.data]?.dictionaryValue {
            
            // In new v2 API last updated will be inside data
            if let tempLastUpdated = data[Fields.lastUpdated]?.stringValue {
                
                if let date = HATFormatterHelper.formatStringToDate(string: tempLastUpdated) {
                    
                    lastUpdated = Int(HATFormatterHelper.formatDateToEpoch(date: date)!)
                }
            }
            if let tempSilhouette = dict[Fields.isSilhouette]?.boolValue {
                
                isSilhouette = tempSilhouette
            }
            if let tempHeight = dict[Fields.height]?.string {
                
                imageHeight = Int(tempHeight)!
            }
            if let tempWidth = dict[Fields.width]?.stringValue {
                
                imageWidth = Int(tempWidth)!
            }
            if let tempLink = dict[Fields.url]?.stringValue {
                
                url = tempLink
            }
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
            
            Fields.recordID: self.recordID ?? "-1",
            Fields.isSilhouette: self.isSilhouette,
            Fields.url: self.url,
            Fields.height: self.imageHeight,
            Fields.width: self.imageWidth,
            Fields.endPoint: self.endPoint,
            Fields.lastUpdated: HATFormatterHelper.formatDateToISO(date: Date())
        ]
    }
}
