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

public struct DataDebitBundleContextlessObject {
    
    // MARK: - Fields
    
    private struct Fields {
        
        static let bundleID: String = "id"
        static let dateCreated: String = "dateCreated"
        static let lastUpdated: String = "lastUpdated"
        static let name: String = "name"
    }
    
    // MARK: - Variables

    public var bundleID: Int = 0
    public var dateCreated: Date?
    public var lastUpdated: Date?
    public var name: String = ""

    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        bundleID = 0
        dateCreated = nil
        lastUpdated = nil
        name = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dictionary: Dictionary<String, JSON>) {
        
        if let tempBundleID = dictionary[Fields.bundleID]?.int {
            
            bundleID = tempBundleID
        }
        
        if let tempDateCreated = dictionary[Fields.dateCreated]?.string {
            
            dateCreated = HATFormatterHelper.formatStringToDate(string: tempDateCreated)
        }
        
        if let tempLastDate = dictionary[Fields.lastUpdated]?.string {
            
            lastUpdated = HATFormatterHelper.formatStringToDate(string: tempLastDate)
        }
        
        if let tempName = dictionary[Fields.name]?.string {
            
            name = tempName
        }
    }
}
