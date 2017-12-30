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

public struct HATNotesV2Object: HATObject, HatApiType {

    // MARK: - JSON Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let endpoint: String = "endpoint"
        static let recordId: String = "recordId"
        static let data: String = "data"
    }
    
    // MARK: - Variables
    
    /// the author data
    public var endpoint: String = ""
    
    /// the photo data
    public var recordId: String = ""
    
    /// the location data
    public var data: HATNotesV2DataObject = HATNotesV2DataObject()
    
    // MARK: - Initialiser
    
    public init() {
        
    }
    
    public init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        self.inititialize(dict: dict)
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public mutating func inititialize(dict: Dictionary<String, JSON>) {
        
        if let tempEndpoint = dict[Fields.endpoint]?.string {
            
            endpoint = tempEndpoint
        }
        
        if let tempRecordId = dict[Fields.recordId]?.string {
            
            recordId = tempRecordId
        }
        
        if let tempData = dict[Fields.data]?.dictionaryValue {
            
            data = HATNotesV2DataObject(dict: tempData)
        }
    }
    
    // MARK: - HatApiType Protocol
    
    public func toJSON() -> Dictionary<String, Any> {
        
        return [ Fields.endpoint: endpoint,
                 Fields.recordId: recordId,
                 Fields.data: data.toJSON()
        ]
    }
    
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let dictionary = JSON(fromCache)
        self.inititialize(dict: dictionary.dictionaryValue)
    }
}
