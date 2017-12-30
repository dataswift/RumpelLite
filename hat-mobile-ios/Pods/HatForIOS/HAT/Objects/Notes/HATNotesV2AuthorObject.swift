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

public struct HATNotesV2AuthorObject: HATObject, HatApiType {

    // MARK: - JSON Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let authorID: String = "id"
        static let phata: String = "phata"
        static let nick: String = "nick"
        static let name: String = "name"
        static let photoURL: String = "photo_url"
    }
    
    // MARK: - Variables
    
    /// the nickname of the author
    public var nickname: String?
    /// the name of the author
    public var name: String?
    /// the photo url of the author
    public var photo_url: String?
    /// the phata of the author. Required
    public var phata: String = ""
    
    /// the id of the author
    public var authorID: Int?
    
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
        
        // this field will always have a value no need to use if let
        if let tempPHATA = dict[Fields.phata]?.string {
            
            phata = tempPHATA
        }
        
        // check optional fields for value, if found assign it to the correct variable
        if let tempID = dict[Fields.authorID]?.stringValue {
            
            // check if string is "" as well
            if tempID != "" {
                
                if let intTempID = Int(tempID) {
                    
                    authorID = intTempID
                }
            }
        }
        
        if let tempNickName = dict[Fields.nick]?.string {
            
            nickname = tempNickName
        }
        
        if let tempName = dict[Fields.name]?.string {
            
            name = tempName
        }
        
        if let tempPhotoURL = dict[Fields.photoURL]?.string {
            
            photo_url = tempPhotoURL
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
            
            Fields.phata: self.phata,
            Fields.authorID: self.authorID ?? "",
            Fields.nick: self.nickname ?? "",
            Fields.name: self.name ?? "",
            Fields.photoURL: self.photo_url ?? ""
        ]
    }
}
