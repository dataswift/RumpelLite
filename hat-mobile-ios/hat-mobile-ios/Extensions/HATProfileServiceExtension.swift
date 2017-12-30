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

import HatForIOS

extension HATProfileService {
    
    public static let addressMapping = [
        "(0, 0)": "address.city",
        "(1, 0)": "address.county",
        "(2, 0)": "address.country"
    ]
    
    public static let personalMapping = [
        "(0, 0)": "personal.firstName",
        "(1, 0)": "personal.lastName",
        "(2, 0)": "personal.middleName",
        "(3, 0)": "personal.preferredName",
        "(4, 0)": "personal.title"
        ]
    
    public static let phoneMapping = [
        "(0, 0)": "contact.mobile",
        "(1, 0)": "contact.landline"
        ]
    
    public static let emailMapping = [
        "(0, 0)": "contact.primaryEmail",
        "(1, 0)": "contact.alternativeEmail"
    ]
    
    public static let emergencyContactMapping = [
        "(0, 0)": "emergencyContact.firstName",
        "(1, 0)": "emergencyContact.lastName",
        "(2, 0)": "emergencyContact.relationship",
        "(3, 0)": "emergencyContact.phoneNumber"
    ]
    
    public static let personalInfoMapping = [
        "(0, 0)": "personal.age",
        "(1, 0)": "personal.gender",
        "(2, 0)": "personal.birth",
        "(3, 0)": "personal.nickname"
    ]
    
    public static let onlineMapping = [
        "(0, 0)": "online.website",
        "(1, 0)": "online.blog",
        "(2, 0)": "online.facebook",
        "(3, 0)": "online.twitter",
        "(4, 0)": "online.google",
        "(5, 0)": "online.linkedin",
        "(6, 0)": "online.youtube"
    ]
    
    public static let aboutMapping = [
        "(0, 0)": "about.body"
    ]
    
    static let initAddressMapping = [
        "(0, 0)": FieldInfo(string: \HATProfileObjectV2.data.address.city, tag: 0, placeholder: "City"),
        "(1, 0)": FieldInfo(string: \HATProfileObjectV2.data.address.county, tag: 0, placeholder: "County"),
        "(2, 0)": FieldInfo(string: \HATProfileObjectV2.data.address.country, tag: 5, placeholder: "Country")
    ]
    
    static let initPersonalMapping = [
        "(0, 0)": FieldInfo(string: \HATProfileObjectV2.data.personal.firstName, tag: 0, placeholder: "First Name"),
        "(1, 0)": FieldInfo(string: \HATProfileObjectV2.data.personal.lastName, tag: 0, placeholder: "Last Name"),
        "(2, 0)": FieldInfo(string: \HATProfileObjectV2.data.personal.middleName, tag: 5, placeholder: "Middle Name"),
        "(3, 0)": FieldInfo(string: \HATProfileObjectV2.data.personal.preferredName, tag: 0, placeholder: "Preferred Name"),
        "(4, 0)": FieldInfo(string: \HATProfileObjectV2.data.personal.title, tag: 5, placeholder: "Title")
    ]
    
    static let initPhoneMapping = [
        "(0, 0)": FieldInfo(string: \HATProfileObjectV2.data.contact.mobile, tag: 0, placeholder: "Mobile Phone"),
        "(1, 0)": FieldInfo(string: \HATProfileObjectV2.data.contact.landline, tag: 0, placeholder: "Phone")
    ]
    
    static let initEmergencyContactMapping = [
        "(0, 0)": FieldInfo(string: \HATProfileObjectV2.data.emergencyContact.firstName, tag: 0, placeholder: "First Name"),
        "(1, 0)": FieldInfo(string: \HATProfileObjectV2.data.emergencyContact.lastName, tag: 0, placeholder: "Last Name"),
        "(2, 0)": FieldInfo(string: \HATProfileObjectV2.data.emergencyContact.relationship, tag: 5, placeholder: "Relationship"),
        "(3, 0)": FieldInfo(string: \HATProfileObjectV2.data.emergencyContact.mobile, tag: 0, placeholder: "Phone Number")
    ]
    
    static let initOnlineMapping = [
        "(0, 0)": FieldInfo(string: \HATProfileObjectV2.data.online.website, tag: 0, placeholder: "Website"),
        "(1, 0)": FieldInfo(string: \HATProfileObjectV2.data.online.blog, tag: 0, placeholder: "Blog"),
        "(2, 0)": FieldInfo(string: \HATProfileObjectV2.data.online.facebook, tag: 0, placeholder: "Facebook"),
        "(3, 0)": FieldInfo(string: \HATProfileObjectV2.data.online.twitter, tag: 0, placeholder: "Twitter"),
        "(4, 0)": FieldInfo(string: \HATProfileObjectV2.data.online.google, tag: 0, placeholder: "Google"),
        "(5, 0)": FieldInfo(string: \HATProfileObjectV2.data.online.linkedin, tag: 0, placeholder: "Linkedin"),
        "(6, 0)": FieldInfo(string: \HATProfileObjectV2.data.online.youtube, tag: 0, placeholder: "Youtube")
    ]
    
    public static func mapStructure(_ structure: Dictionary<String, String>, with returnedDictionary: Dictionary<String, String>) -> Dictionary<String, String> {
        
        let filtered = structure.filter({ item1 in
            
            for item2 in returnedDictionary {
                
                if item1.value == item2.value {
                    
                    return true
                }
            }
            
            return false
        })
        
        return filtered
    }
}
