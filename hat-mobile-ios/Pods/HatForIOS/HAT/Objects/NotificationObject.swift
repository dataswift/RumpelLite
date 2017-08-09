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

public struct NotificationObject {
    
    // MARK: - Fields
    
    private struct Fields {
        
        static let notice: String = "notice"
        static let received: String = "received"
        static let read: String = "read"
    }
    
    // MARK: - Variables
    
    public var notice: NotificationNoticeObject = NotificationNoticeObject()
    public var received: Date = Date()
    public var read: Date?
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        notice = NotificationNoticeObject()
        received = Date()
        read = nil
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dictionary: Dictionary<String, JSON>) {
        
        if let tempNotice = dictionary[Fields.notice]?.dictionary {
            
            notice = NotificationNoticeObject(dictionary: tempNotice)
        }
        
        if let tempReceivedDate = dictionary[Fields.received]?.intValue {
            
            received = Date(timeIntervalSince1970: TimeInterval(tempReceivedDate))
        }
        
        if let tempReadDate = dictionary[Fields.read]?.intValue {
            
            read = Date(timeIntervalSince1970: TimeInterval(tempReadDate))
        }
    }

}
