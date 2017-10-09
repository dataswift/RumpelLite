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
import SwiftyJSON

// MARK: Struct

internal struct PhysicalActivityCachingWrapperHelper {

    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestSurveyObject(userToken: String, userDomain: String, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([SurveyObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATAccountService.getHatTableValuesv2(
                token: userToken,
                userDomain: userDomain,
                namespace: Constants.HATTableName.PhysicalActivityAnswers.source,
                scope: Constants.HATTableName.PhysicalActivityAnswers.name,
                parameters: ["take": "1", "orderBy": "unixTimeStamp", "ordering": "descending"],
                successCallback: { json, newToken in
                    
                    var arrayToReturn: [SurveyObject] = []

                    if !json.isEmpty {
                        
                        if let array = json[0].dictionary?["data"]?["array"].array {
                            
                            for item in array {
                                
                                arrayToReturn.append(SurveyObject(from: item))
                            }
                        }
                    }
                    
                    successRespond(arrayToReturn, newToken)
                },
                errorCallback: failRespond)
        }
    }
    
    // MARK: - Get system status
    
    /**
     Gets the system status from the hat
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter cacheTypeID: The cache type to request
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter successRespond: A completion function of type ([HATNotesData], String?) -> Void
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     */
    static func getSurveyObject(userToken: String, userDomain: String, cacheTypeID: String, successRespond: @escaping ([SurveyObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        PhysicalActivityCachingWrapperHelper.checkForUnsyncedSurveyObjectToUpdate(
            userDomain: userDomain,
            userToken: userToken)
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.day,
            value: 1,
            networkRequest: PhysicalActivityCachingWrapperHelper.requestSurveyObject(userToken: userToken, userDomain: userDomain, failRespond: failRespond),
            completion: successRespond
        )
    }
    
    // MARK: - Post
    
    /**
     Posts a note
     
     - parameter note: The note to be posted
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     */
    static func postSurveyObject(surveyObjects: [SurveyObject], userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        CachingHelper.deleteFromRealm(type: "physicalActivity")
        CachingHelper.deleteFromRealm(type: "physicalActivity-Post")
        
        // creating note to be posted in cache
        var array: [Dictionary<String, Any>] = []
        for survey in surveyObjects {
            
            array.append(survey.toJSON())
        }
        
        // adding note to be posted in cache
        do {
            
            let realm = RealmHelper.getRealm()
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: array, type: "physicalActivity", expiresIn: .day, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: array, type: "physicalActivity-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
            }
        } catch {
            
            print("adding to profile to update failed")
        }
        
        PhysicalActivityCachingWrapperHelper.checkForUnsyncedSurveyObjectToUpdate(
            userDomain: userDomain,
            userToken: userToken,
            completion: successCallback,
            errorCallback: errorCallback)
    }
    
    /**
     Checks for unsynced notes to post
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     */
    static func checkForUnsyncedSurveyObjectToUpdate(userDomain: String, userToken: String, completion: (() -> Void)? = nil, errorCallback: ((HATTableError) -> Void)? = nil) {
        
        // Try deleting the notes
        func tryUpdating(infoArray: [JSONCacheObject]) {
            
            // for each note parse it and try to delete it
            for tempInfo in infoArray where tempInfo.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: tempInfo.jsonData!) as? [Dictionary<String, Any>] {
                    
                    var array: [Dictionary<String, Any>] = []
                    for survey in dictionary {
                        
                        let surveyObject = SurveyObject(fromCache: survey)
                        array.append(surveyObject.toJSON())
                    }
                    
                    func success(json: JSON, newToken: String?) {
                        
                        CachingHelper.deleteFromRealm(type: "physicalActivity-Post")
                        completion?()
                    }
                    
                    func failed(error: HATTableError) {
                        
                        errorCallback?(error)
                        CrashLoggerHelper.hatTableErrorLog(error: error)
                    }
                    
                    HATAccountService.createTableValuev2(
                        token: userToken,
                        userDomain: userDomain,
                        source: Constants.HATTableName.PhysicalActivityAnswers.source,
                        dataPath: Constants.HATTableName.PhysicalActivityAnswers.name,
                        parameters: ["array": array,
                                     "unixTimeStamp": SurveyObject.createUnixTimeStamp()],
                        successCallback: success,
                        errorCallback: failed)
                }
            }
            
            completion?()
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "physicalActivity-Post", sync: tryUpdating)
    }
}
