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

public struct HATProfileDataProfilePersonalObjectV2: HATObject, HatApiType {
    
    // MARK: - Fields
    
    struct Fields {
        
        static let title: String = "title"
        static let gender: String = "gender"
        static let ageGroup: String = "ageGroup"
        static let middleName: String = "middleName"
        static let preferredName: String = "preferredName"
        static let lastName: String = "lastName"
        static let nickName: String = "nickName"
        static let firstName: String = "firstName"
        static let birthDate: String = "birthDate"
    }
    
    public var title: String = ""
    public var gender: String = ""
    public var ageGroup: String = ""
    public var middleName: String = ""
    public var preferredName: String = ""
    public var lastName: String = ""
    public var nickName: String = ""
    public var firstName: String = ""
    public var birthDate: String = ""
    
    public init() {
        
    }
    
    public init(dict: Dictionary<String, JSON>) {
        
        self.init()
        
        self.initialize(dict: dict)
    }
    
    public mutating func initialize(dict: Dictionary<String, JSON>) {
        
        if let tempTitle = (dict[Fields.title]?.stringValue) {
            
            title = tempTitle
        }
        if let tempGender = (dict[Fields.gender]?.stringValue) {
            
            gender = tempGender
        }
        if let tempAgeGroup = (dict[Fields.ageGroup]?.stringValue) {
            
            ageGroup = tempAgeGroup
        }
        if let tempMiddleName = (dict[Fields.middleName]?.stringValue) {
            
            middleName = tempMiddleName
        }
        if let tempPreferredName = (dict[Fields.preferredName]?.stringValue) {
            
            preferredName = tempPreferredName
        }
        if let tempLastName = (dict[Fields.lastName]?.stringValue) {
            
            lastName = tempLastName
        }
        if let tempNickName = (dict[Fields.nickName]?.stringValue) {
            
            nickName = tempNickName
        }
        if let tempFirstName = (dict[Fields.firstName]?.stringValue) {
            
            firstName = tempFirstName
        }
        if let tempBirthDate = (dict[Fields.birthDate]?.stringValue) {
            
            birthDate = tempBirthDate
        }
    }
    
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            Fields.title: self.title,
            Fields.gender: self.gender,
            Fields.ageGroup: self.ageGroup,
            Fields.middleName: self.middleName,
            Fields.preferredName: self.preferredName,
            Fields.lastName: self.lastName,
            Fields.nickName: self.nickName,
            Fields.firstName: self.firstName,
            Fields.birthDate: self.birthDate
        ]
    }
    
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let json = JSON(fromCache)
        self.initialize(dict: json.dictionaryValue)
    }
}
