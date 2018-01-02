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

import Alamofire
import SwiftyJSON

// MARK: Struct

public struct HATProfileService {
    
    // MARK: - Get profile nationality
    
    /**
     Gets the nationality of the user from the hat, if it's there already
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func getNationalityFromHAT(userDomain: String, userToken: String, successCallback: @escaping (HATNationalityObject) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        func profileEntries(json: [JSON], renewedToken: String?) {
            
            // if we have values return them
            if !json.isEmpty {
                
                let array = HATNationalityObject(from: json.last!)
                successCallback(array)
            } else {
                
                failCallback(.noValuesFound)
            }
        }
        
        HATAccountService.getHatTableValuesv2(token: userToken, userDomain: userDomain, namespace: "rumpel", scope: "nationality", parameters: ["starttime": "0"], successCallback: profileEntries, errorCallback: failCallback)
    }
    
    // MARK: - Post profile nationality
    
    /**
     Posts user's nationality to the hat
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter nationality: The user's token
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func postNationalityToHAT(userDomain: String, userToken: String, nationality: HATNationalityObject, successCallback: @escaping (HATNationalityObject) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        let json = nationality.toJSON()
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: "rumpel",
            dataPath: "nationality",
            parameters: json,
            successCallback: { (json, _) in
                
                successCallback(HATNationalityObject(from: json))
        },
            errorCallback: failCallback)
    }
    
    // MARK: - Get profile relationship and household
    
    /**
     Gets the profile relationship and household of the user from the hat, if it's there already
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func getRelationshipAndHouseholdFromHAT(userDomain: String, userToken: String, successCallback: @escaping (HATProfileRelationshipAndHouseholdObject) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        func profileEntries(json: [JSON], renewedToken: String?) {
            
            // if we have values return them
            if !json.isEmpty {
                
                let array = HATProfileRelationshipAndHouseholdObject(from: json.last!)
                successCallback(array)
            } else {
                
                failCallback(.noValuesFound)
            }
        }
        
        HATAccountService.getHatTableValuesv2(token: userToken, userDomain: userDomain, namespace: "rumpel", scope: "relationshipAndHousehold", parameters: ["starttime": "0"], successCallback: profileEntries, errorCallback: failCallback)
    }
    
    // MARK: - Post profile relationship and household
    
    /**
     Posts user's profile relationship and household to the hat
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter relationshipAndHouseholdObject: The user's relationship and household data
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func postRelationshipAndHouseholdToHAT(userDomain: String, userToken: String, relationshipAndHouseholdObject: HATProfileRelationshipAndHouseholdObject, successCallback: @escaping (HATProfileRelationshipAndHouseholdObject) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        let json = relationshipAndHouseholdObject.toJSON()
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: "rumpel",
            dataPath: "relationshipAndHousehold",
            parameters: json,
            successCallback: {  (json, _) in
                
                successCallback(HATProfileRelationshipAndHouseholdObject(from: json))
        },
            errorCallback: failCallback
        )
    }
    
    // MARK: - Get profile education
    
    /**
     Gets the profile education of the user from the hat, if it's there already
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func getEducationFromHAT(userDomain: String, userToken: String, successCallback: @escaping (HATProfileEducationObject) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        func profileEntries(json: [JSON], renewedToken: String?) {
            
            // if we have values return them
            if !json.isEmpty {
                
                let array = HATProfileEducationObject(from: json.last!)
                successCallback(array)
            } else {
                
                failCallback(.noValuesFound)
            }
        }
        
        HATAccountService.getHatTableValuesv2(token: userToken, userDomain: userDomain, namespace: "rumpel", scope: "education", parameters: ["starttime": "0"], successCallback: profileEntries, errorCallback: failCallback)
    }
    
    // MARK: - Post profile education
    
    /**
     Posts user's profile education to the hat
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter education: The user's education
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func postEducationToHAT(userDomain: String, userToken: String, education: HATProfileEducationObject, successCallback: @escaping (HATProfileEducationObject) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        let json = education.toJSON()
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: "rumpel",
            dataPath: "education",
            parameters: json,
            successCallback: { (json, _) in
                
                successCallback(HATProfileEducationObject(from: json))
        },
            errorCallback: failCallback
        )
    }
    
    // MARK: - Get Profile
    
    /**
     Gets the profile education of the user from the hat, if it's there already
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func getProfile(userDomain: String, userToken: String, successCallback: @escaping (HATProfileObjectV2, String?) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        func profileEntries(json: [JSON], renewedToken: String?) {
            
            // if we have values return them
            if !json.isEmpty {
                
                if let profile: HATProfileObjectV2 = HATProfileObjectV2.decode(from: json[0].dictionaryValue) {
                    
                    successCallback(profile, renewedToken)
                } else {
                    
                    failCallback(.noValuesFound)
                }
            } else {
                
                failCallback(.noValuesFound)
            }
        }
        
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            namespace: "rumpel",
            scope: "profile",
            parameters: ["ordering": "descending", "orderBy": "dateCreated"],
            successCallback: profileEntries,
            errorCallback: failCallback)
    }
    
    public static func postProfile(userToken: String, userDomain: String, profile: HATProfileObjectV2, successCallback: @escaping (HATProfileObjectV2, String?) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        guard let profileJSON: Dictionary<String, Any> = HATProfileDataObjectV2.encode(from: profile.data) else {
            
            return
        }
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: "rumpel",
            dataPath: "profile",
            parameters: profileJSON,
            successCallback: { (json, newToken) in
                
                guard let profile: HATProfileObjectV2 = HATProfileObjectV2.decode(from: json.dictionaryValue) else {
                    
                    failCallback(.noValuesFound)
                    return
                }
                
                successCallback(profile, newToken)
        },
            errorCallback: failCallback)
    }
    
    // MARK: - Get Profile Image
    
    /**
     Gets the profile education of the user from the hat, if it's there already
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func getProfileImageFromHAT(userDomain: String, userToken: String, successCallback: @escaping (FileUploadObject) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        func profileEntries(json: [JSON], renewedToken: String?) {
            
            // if we have values return them
            if !json.isEmpty {
                
                let array = FileUploadObject(from: (json.last?.dictionaryValue)!)
                successCallback(array)
            } else {
                
                failCallback(.noValuesFound)
            }
        }
        
        HATAccountService.getHatTableValuesv2(token: userToken, userDomain: userDomain, namespace: "rumpel", scope: "profileImage", parameters: ["starttime": "0"], successCallback: profileEntries, errorCallback: failCallback)
    }
    
    // MARK: - Post profile Image
    
    /**
     Posts user's profile education to the hat
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter education: The user's education
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func postProfileImageToHAT(userDomain: String, userToken: String, image: FileUploadObject, successCallback: @escaping (FileUploadObject) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        let json = image.toJSON()
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: "rumpel",
            dataPath: "profileImage",
            parameters: json,
            successCallback: { (json, _) in
                
                successCallback(FileUploadObject(from: json.dictionaryValue))
        },
            errorCallback: failCallback
        )
    }
    
    // MARK: - Get Stuff To Remember
    
    /**
     Gets the stuff to remember of the user from the hat, if it's there already
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func getStuffToRememberFromHAT(userDomain: String, userToken: String, successCallback: @escaping ([StuffToRememberObject], String?) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        func stuffToRemember(json: [JSON], renewedToken: String?) {
            
            // if we have values return them
            if !json.isEmpty {
                
                var arrayToReturn: [StuffToRememberObject] = []
                
                for item in json {
                    
                    arrayToReturn.append(StuffToRememberObject(dictionary: item.dictionaryValue))
                }
                
                successCallback(arrayToReturn, renewedToken)
            } else {
                
                failCallback(.noValuesFound)
            }
        }
        
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            namespace: "rumpel",
            scope: "stufftoremember",
            parameters: ["starttime": "0"],
            successCallback: stuffToRemember,
            errorCallback: failCallback)
    }
    
    // MARK: - Post Stuff To Remember
    
    /**
     Posts user's stuff to remember
     
     - parameter userDomain: The user's HAT domain
     - parameter userToken: The user's token
     - parameter stuffToRemember: The user's stuff to remember
     - parameter successCallback: A function to call on success
     - parameter failCallback: A fuction to call on fail
     */
    public static func postStuffToRememberToHAT(userDomain: String, userToken: String, stuffToRemember: StuffToRememberObject, successCallback: @escaping (StuffToRememberObject, String?) -> Void, failCallback: @escaping (HATTableError) -> Void) {
        
        let json = stuffToRemember.toJSON()
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: "rumpel",
            dataPath: "stufftoremember",
            parameters: json,
            successCallback: { (json, newToken) in
                
                successCallback(StuffToRememberObject(dictionary: json.dictionaryValue), newToken)
        },
            errorCallback: failCallback
        )
    }
    
    public static func getPhataStructureBundle(userDomain: String, userToken: String, parameters: Dictionary<String, Any> = [:], success: @escaping (Dictionary<String, JSON>) -> Void, fail: @escaping (HATTableError) -> Void) {
        
        if let url: URLConvertible = URL(string: "https://\(userDomain)/api/v2/data-bundle/phata/structure") {
            
            Alamofire.request(
                url,
                method: .get,
                parameters: parameters,
                encoding: Alamofire.JSONEncoding.default,
                headers: ["x-auth-token": userToken]).responseJSON(completionHandler: { response in
                    
                    switch response.result {
                    case .success:
                        
                        if response.response?.statusCode == 404 {
                            
                            fail(HATTableError.generalError("json creation failed", nil, nil))
                        } else if response.response?.statusCode == 200 {
                            
                            if let value = response.result.value {
                                
                                let json = JSON(value)
                                let dict = json["bundle"]["profile"]["endpoints"][0]["mapping"].dictionary
                                success(dict ?? [:])
                            }
                        }
                    case .failure(let error):
                        
                        fail(HATTableError.generalError("", nil, error))
                    }
                }
            )
        }
    }
    
    public static let notablesStructure = [
        "notables":
            [
                "endpoints": [
                    [
                        "filters": [
                            [
                                "field": "shared",
                                "operator":
                                    [
                                        "value": true,
                                        "operator": "contains"
                                ]
                            ],
                            [
                                "field": "shared_on",
                                "operator":
                                    [
                                        "value": "phata",
                                        "operator": "contains"
                                ]
                            ]],
                        "mapping":
                            [
                                "kind": "kind",
                                "shared": "shared",
                                "message": "message",
                                "author": "authorv1",
                                "location": "locationv1",
                                "shared_on": "shared_on",
                                "created_time": "created_time",
                                "public_until": "public_until",
                                "updated_time": "updated_time"
                        ],
                        "endpoint": "rumpel/notablesv1"
                    ]],
                "orderBy": "updated_time",
                "ordering": "descending"
        ]
    ]
    
    public static func constructDictionaryForBundle(mutableDictionary: NSMutableDictionary) -> Dictionary<String, Any>? {
        
        if let dict = mutableDictionary as? Dictionary<String, String> {
            
            let profileStructure = ["profile":
                [
                    "endpoints": [
                        [
                            "endpoint": "rumpel/profile",
                            "mapping": dict
                        ]
                    ],
                    "orderBy": "dateCreated",
                    "ordering": "descending",
                    "limit": 1
                ]
            ]
            
            let notablesStructure = HATProfileService.notablesStructure
            
            let temp = NSMutableDictionary()
            temp.addEntries(from: profileStructure)
            temp.addEntries(from: notablesStructure)
            
            if let dictionaryToReturn = temp as? Dictionary<String, Any> {
                
                return dictionaryToReturn
            }
        }
        
        return nil
    }
    
    public static func createPhataStructureBundle(userDomain: String, userToken: String, parameters: Dictionary<String, Any>? = nil, success: @escaping (Bool) -> Void, fail: @escaping (HATTableError) -> Void) {
        
        if let url: URLConvertible = URL(string: "https://\(userDomain)/api/v2/data-bundle/phata") {
            
            let parametersToSend: Dictionary<String, Any>
            
            if parameters == nil {
                
                parametersToSend = HATProfileService.notablesStructure
            } else {
                
                let mutableDictionary = NSMutableDictionary()
                mutableDictionary.addEntries(from: HATProfileService.notablesStructure)
                mutableDictionary.addEntries(from: parameters!)
                guard let tempDict = mutableDictionary as? Dictionary<String, Any> else {
                    
                    parametersToSend = [:]
                    return
                }
                parametersToSend = tempDict
            }
            
            Alamofire.request(
                url,
                method: .post,
                parameters: parametersToSend,
                encoding: Alamofire.JSONEncoding.default,
                headers: ["x-auth-token": userToken]).responseJSON(completionHandler: { response in
                    
                    switch response.result {
                    case .success:
                        
                        if response.response?.statusCode == 201 {
                            
                            success(true)
                        } else {
                            
                            success(false)
                        }
                    case .failure(let error):
                        
                        fail(HATTableError.generalError("", nil, error))
                    }
                }
            )
        }
    }
    
    public static func createAndGetProfileBundle(userDomain: String, userToken: String, parameters: Dictionary<String, Any>? = nil, success: @escaping (Dictionary<String, JSON>) -> Void, fail: @escaping (HATTableError) -> Void) {
        
        func bundleCreated(isBundleCreated: Bool) {
            
            if isBundleCreated {
                
                HATProfileService.getPhataStructureBundle(
                    userDomain: userDomain,
                    userToken: userToken,
                    parameters: [:],
                    success: success,
                    fail: fail)
            }
        }
        
        HATProfileService.createPhataStructureBundle(
            userDomain: userDomain,
            userToken: userToken,
            parameters: parameters,
            success: bundleCreated,
            fail: fail)
    }
}
