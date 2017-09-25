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

import RealmSwift

// MARK: Class

public class JSONCacheObject: Object {
    
    // MARK: - Variables
    
    /// The object's dictionary of type <String, Any> converted to Data
    @objc dynamic var jsonData: Data?
    
    /// The date that this object was created
    @objc dynamic var dateAdded: Date?
    /// The date that this object was synced
    @objc dynamic var lastSyncedDate: Date?
    /// The date that this object will expire
    @objc dynamic var expiryDate: Date?
    
    /// A String to identify what kind of object is this (note, locations etc)
    @objc dynamic var type: String = ""
    /// A String to identify each record
    @objc dynamic var uniqueKey: String = ""
    
    // MARK: - Initialiser
    
    /**
     Inits an object to the values we want
     
     - parameter dictionary: An array of Dictionaries of type <String, Any> representing the model we want
     - parameter type: A string to identify what type of object is that (note, locations etc)
     - parameter expiresIn: An optional Calendar.Component type indicating the period(Hour, Day, Month, etc) to expire
     - parameter value: An optional Int indicating the value of expiresIn. If value = 2 and expiresIn = .day then it will expire in 2 days
     */
    convenience init(dictionary: [Dictionary<String, Any>], type: String, expiresIn: Calendar.Component?, value: Int?) {
        
        self.init()
        
        self.jsonData = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        self.dateAdded = Date()
        self.type = type
        self.uniqueKey = UUID().uuidString
        self.expiryDate = self.calculateExpiryDateFrom(date: self.dateAdded, expiresIn: expiresIn, value: value)
    }
    
    // MARK: - Calculate Expiry Date
    
    /**
     Calculate the expiry date of the object
     
     - parameter date: The date added. Start calculating from this date
     - parameter expiresIn: An optional Calendar.Component type indicating the period(Hour, Day, Month, etc) to expire
     - parameter value: An optional Int indicating the value of expiresIn. If value = 2 and expiresIn = .day then it will expire in 2 days
     */
    private func calculateExpiryDateFrom(date: Date?, expiresIn: Calendar.Component?, value: Int?) -> Date? {
        
        if expiresIn != nil && value != nil && date != nil {
            
            let calendar = Calendar.current
            return calendar.date(byAdding: expiresIn!, value: value!, to: date!)
        }
        
        return nil
    }
}
