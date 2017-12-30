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

public struct HATNotesV2PhotoObject: HATObject, HatApiType {

    // MARK: - JSON Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let link: String = "link"
        static let source: String = "source"
        static let caption: String = "caption"
        static let shared: String = "shared"
    }
    
    // MARK: - Variables
    
    /// the link to the photo
    public var link: String?
    /// the source of the photo
    public var source: String?
    /// the caption of the photo
    public var caption: String?
    
    /// if photo is shared
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
        
        // check if shared exists and if is empty
        if let tempShared = dict[Fields.shared]?.string {
            
            if let boolResult = Bool(tempShared) {
                
                shared = boolResult
            }
        }
        
        if let tempLink = dict[Fields.link]?.string {
            
            link = tempLink
        }
        
        if let tempSource = dict[Fields.source]?.string {
            
            source = tempSource
        }
        
        if let tempCaption = dict[Fields.caption]?.string {
            
            caption = tempCaption
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
            
            Fields.shared: String(describing: self.shared),
            Fields.link: self.link ?? "",
            Fields.source: self.source ?? "",
            Fields.caption: self.caption ?? ""
        ]
    }
}
