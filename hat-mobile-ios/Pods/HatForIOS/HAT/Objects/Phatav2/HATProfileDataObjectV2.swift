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

public struct HATProfileDataObjectV2: HATObject, HatApiType {
    
    /// The possible Fields of the JSON struct
    public struct Fields {
        
        static let about: String = "about"
        static let photo: String = "photo"
        static let online: String = "online"
        static let address: String = "address"
        static let contact: String = "contact"
        static let personal: String = "personal"
        static let emergencyContact: String = "emergencyContact"
        static let dateCreated: String = "dateCreated"
        static let dateCreatedLocal: String = "dateCreatedLocal"
        static let shared: String = "shared"
    }
    
    /// The website object of user's profile
    public var about: HATProfileDataProfileAboutObjectV2 = HATProfileDataProfileAboutObjectV2()
    /// The nickname object of user's profile
    public var photo: HATProfileDataProfilePhotoObjectV2 = HATProfileDataProfilePhotoObjectV2()
    /// The primary email address object of user's profile
    public var online: HATProfileDataProfileOnlineObjectV2 = HATProfileDataProfileOnlineObjectV2()
    /// The youtube object of user's profile
    public var address: HATProfileDataProfileAddressObjectV2 = HATProfileDataProfileAddressObjectV2()
    /// The global addres object of user's profile
    public var contact: HATProfileDataProfileContactObjectV2 = HATProfileDataProfileContactObjectV2()
    /// The youtube object of user's profile
    public var personal: HATProfileDataProfilePersonalObjectV2 = HATProfileDataProfilePersonalObjectV2()
    /// The global addres object of user's profile
    public var emergencyContact: HATProfileDataProfileEmergencyContactObjectV2 = HATProfileDataProfileEmergencyContactObjectV2()
    
    public var dateCreated: Int?
    public var dateCreatedLocal: String?
    public var shared: Bool = false
    
    public init() {
        
    }
    
    public init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        self.initialize(dict: dict)
    }
    
    public mutating func initialize(dict: Dictionary<String, JSON>) {
        
        if let tempAbout = (dict[Fields.about]?.dictionaryValue) {
            
            about = HATProfileDataProfileAboutObjectV2(dict: tempAbout)
        }
        if let tempPhoto = (dict[Fields.photo]?.dictionaryValue) {
            
            photo = HATProfileDataProfilePhotoObjectV2(dict: tempPhoto)
        }
        if let tempOnline = (dict[Fields.online]?.dictionaryValue) {
            
            online = HATProfileDataProfileOnlineObjectV2(dict: tempOnline)
        }
        if let tempAddress = (dict[Fields.address]?.dictionaryValue) {
            
            address = HATProfileDataProfileAddressObjectV2(dict: tempAddress)
        }
        if let tempContact = (dict[Fields.contact]?.dictionaryValue) {
            
            contact = HATProfileDataProfileContactObjectV2(dict: tempContact)
        }
        if let tempPersonal = (dict[Fields.personal]?.dictionaryValue) {
            
            personal = HATProfileDataProfilePersonalObjectV2(dict: tempPersonal)
        }
        if let tempEmergencyContact = (dict[Fields.emergencyContact]?.dictionaryValue) {
            
            emergencyContact = HATProfileDataProfileEmergencyContactObjectV2(dict: tempEmergencyContact)
        }
        if let tempDateCreated = (dict[Fields.dateCreated]?.intValue) {
            
            dateCreated = tempDateCreated
        }
        if let tempDateCreatedLocal = (dict[Fields.dateCreatedLocal]?.stringValue) {
            
            dateCreatedLocal = tempDateCreatedLocal
        }
        if let tempShared = (dict[Fields.shared]?.boolValue) {
            
            shared = tempShared
        }
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            Fields.about: self.about.toJSON(),
            Fields.photo: self.photo.toJSON(),
            Fields.online: self.online.toJSON(),
            Fields.address: self.address.toJSON(),
            Fields.contact: self.contact.toJSON(),
            Fields.personal: self.personal.toJSON(),
            Fields.emergencyContact: self.emergencyContact.toJSON(),
            Fields.dateCreated: self.dateCreated ?? Date().timeIntervalSince1970,
            Fields.dateCreatedLocal: self.dateCreatedLocal ?? HATFormatterHelper.formatDateToISO(date: Date()),
            Fields.shared: self.shared
        ]
    }
    
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let json = JSON(fromCache)
        self.initialize(dict: json.dictionaryValue)
    }
}
