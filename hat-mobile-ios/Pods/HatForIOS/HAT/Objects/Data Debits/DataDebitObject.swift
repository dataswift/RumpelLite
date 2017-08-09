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

public struct DataDebitObject {
    
    // MARK: - Fields
    
    private struct Fields {
        
        static let key: String = "key"
        static let dateCreated: String = "dateCreated"
        static let lastUpdated: String = "lastUpdated"
        static let name: String = "name"
        static let startDate: String = "startDate"
        static let endDate: String = "endDate"
        static let enabled: String = "enabled"
        static let rolling: String = "rolling"
        static let sell: String = "sell"
        static let price: String = "price"
        static let kind: String = "kind"
        static let bundleContextless: String = "bundleContextless"
    }
    
    // MARK: - Variables
    
    public var key: String = ""
    public var dateCreated: Date?
    public var lastUpdated: Date?
    public var name: String = ""
    public var startDate: Date?
    public var endDate: Date?
    public var enabled: String = ""
    public var rolling: String = ""
    public var sell: String = ""
    public var price: Int = 0
    public var kind: String = ""
    public var bundleContextless: DataDebitBundleContextlessObject = DataDebitBundleContextlessObject()
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        key = ""
        dateCreated = nil
        lastUpdated = nil
        name = ""
        startDate = nil
        endDate = nil
        enabled = ""
        rolling = ""
        sell = ""
        price = 0
        kind = ""
        bundleContextless = DataDebitBundleContextlessObject()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dictionary: Dictionary<String, JSON>) {
        
        if let tempKey = dictionary[Fields.key]?.string {
            
            key = tempKey
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
        
        if let tempStartDate = dictionary[Fields.startDate]?.string {
            
            startDate = HATFormatterHelper.formatStringToDate(string: tempStartDate)
        }
        
        if let tempEndDate = dictionary[Fields.endDate]?.string {
            
            endDate = HATFormatterHelper.formatStringToDate(string: tempEndDate)
        }
        
        if let tempEnabled = dictionary[Fields.enabled]?.string {
            
            enabled = tempEnabled
        }
        
        if let tempRolling = dictionary[Fields.rolling]?.string {
            
            rolling = tempRolling
        }
        
        if let tempSell = dictionary[Fields.sell]?.string {
            
            sell = tempSell
        }
        
        if let tempPrice = dictionary[Fields.price]?.int {
            
            price = tempPrice
        }
        
        if let tempKind = dictionary[Fields.kind]?.string {
            
            kind = tempKind
        }
        
        if let tempBundleContextless = dictionary[Fields.bundleContextless]?.dictionary {
            
            bundleContextless = DataDebitBundleContextlessObject(dictionary: tempBundleContextless)
        }
    }
}
