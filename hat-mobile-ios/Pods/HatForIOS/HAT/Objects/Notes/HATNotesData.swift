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

/// A struct representing the outer notes JSON format
public struct HATNotesData: Comparable, HatApiType {
    
    // MARK: - Fields
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let noteID: String = "id"
        static let recordId: String = "recordId"
        static let endPoint: String = "endpoint"
        static let lastUpdated: String = "lastUpdated"
        static let notablesArray: String = "notablesv1"
        static let data: String = "data"
        static let imageData: String = "imageData"
        static let name: String = "name"
    }
    
    // MARK: - Comparable protocol
    
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
    public static func < (lhs: HATNotesData, rhs: HATNotesData) -> Bool {
        
        return lhs.data.updatedTime < rhs.data.updatedTime
    }
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HATNotesData, rhs: HATNotesData) -> Bool {
        
        return lhs.data == lhs.data
    }
    
    // MARK: - Variables
    
    /// the note id
    public var noteID: Int = 0
    
    /// The endPoint of the note, used in v2 API only
    public var endPoint: String = ""
    
    /// The recordID of the note, used in v2 API only
    public var recordID: String = ""
    
    /// the name of the note
    public var name: String  = ""
    
    /// the last updated date of the note
    public var lastUpdated: Date = Date()
    
    /// the data of the note, such as tables about the author, location, photo etc
    public var data: HATNotesNotablesData = HATNotesNotablesData()
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        noteID = 0
        name = ""
        endPoint = ""
        recordID = ""
        lastUpdated = Date()
        data = HATNotesNotablesData()
    }
    
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let dictionary = JSON(fromCache)
        self.inititialize(dict: dictionary.dictionaryValue)
        
        if let value = fromCache[Fields.imageData] as? Data {
            
            data.photoData.image = UIImage(data: value)
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public mutating func inititialize(dict: Dictionary<String, JSON>) {
        
        if let tempID = dict[Fields.noteID]?.int {
            
            noteID = tempID
        }
        if let tempLastUpdated = dict[Fields.lastUpdated]?.stringValue {
            
            lastUpdated = HATFormatterHelper.formatStringToDate(string: tempLastUpdated)!
        }
        if let tempData = dict[Fields.notablesArray]?.dictionary {
            
            data = HATNotesNotablesData.init(dict: tempData)
        }
        
        if noteID == 0 {
            
            noteID = -Int(HATFormatterHelper.formatDateToEpoch(date: data.createdTime)!)!
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dict: Dictionary<String, JSON>) {
        
        if let tempID = dict[Fields.noteID]?.int {
            
            noteID = tempID
        }
        if let tempName = dict[Fields.name]?.string {
            
            name = tempName
        }
        if let tempLastUpdated = dict[Fields.lastUpdated]?.string {
            
            lastUpdated = HATFormatterHelper.formatStringToDate(string: tempLastUpdated)!
        }
        if let tempData = dict[Fields.data]?[Fields.notablesArray].dictionary {
            
            data = HATNotesNotablesData.init(dict: tempData)
        }
    }
    
    /**
     It initialises everything from the received JSON file from the HAT using v2 API
     */
    public init(dictV2: Dictionary<String, JSON>) {
        
        if let tempEndpoint = dictV2[Fields.endPoint]?.string {
            
            endPoint = tempEndpoint
        }
        
        if let tempRecordID = dictV2[Fields.recordId]?.string {
            
            recordID = tempRecordID
        }
        
        if let tempData = dictV2[Fields.data]?.dictionary {
            
            if let tempLastUpdated = tempData[Fields.lastUpdated]?.string {
                
                lastUpdated = HATFormatterHelper.formatStringToDate(string: tempLastUpdated)!
            }
            if let tempNotablesData = tempData[Fields.notablesArray]?.dictionary {
                
                data = HATNotesNotablesData.init(dict: tempNotablesData)
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
            
            Fields.noteID: self.noteID,
            Fields.notablesArray: self.data.toJSON(),
            Fields.lastUpdated: HATFormatterHelper.formatDateToISO(date: Date())
        ]
    }
}
