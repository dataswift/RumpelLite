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

internal struct InterestsCachingWrapperHelper {

    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestInterestObject(userToken: String, userDomain: String, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([InterestsObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATAccountService.getHatTableValuesv2(
                token: userToken,
                userDomain: userDomain,
                namespace: Constants.HATTableName.Interests.source,
                scope: Constants.HATTableName.Interests.name,
                parameters: ["take": "1", "orderBy": "unixTimeStamp", "ordering": "descending"],
                successCallback: { jsonArray, newToken in
            
                    var interestObject = InterestsObject()

                    if !jsonArray.isEmpty {
                        
                        if let tempDictionary = jsonArray[0].dictionary?["data"]?.dictionaryValue {
                            
                            for (key, value) in tempDictionary where value.int != nil {
                                
                                interestObject.dictionary.updateValue(value.intValue, forKey: key)
                            }
                        }
                    }
                    
                    successRespond([interestObject], newToken)
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
    static func getInterestObject(userToken: String, userDomain: String, cacheTypeID: String, successRespond: @escaping ([InterestsObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        InterestsCachingWrapperHelper.checkForUnsyncedInterestObjectToUpdate(
            userDomain: userDomain,
            userToken: userToken)
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.day,
            value: 1,
            networkRequest: InterestsCachingWrapperHelper.requestInterestObject(userToken: userToken, userDomain: userDomain, failRespond: failRespond),
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
    static func postInterestObject(interestObject: InterestsObject, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        CachingHelper.deleteFromRealm(type: "interests")
        CachingHelper.deleteFromRealm(type: "interests-Post")
        
        // adding note to be posted in cache
        do {
            
            let realm = RealmHelper.getRealm()
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [interestObject.toJSON()], type: "interests", expiresIn: .day, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [interestObject.toJSON()], type: "interests-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
            }
        } catch {
            
            print("adding to profile to update failed")
        }
        
        InterestsCachingWrapperHelper.checkForUnsyncedInterestObjectToUpdate(
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
    static func checkForUnsyncedInterestObjectToUpdate(userDomain: String, userToken: String, completion: (() -> Void)? = nil, errorCallback: ((HATTableError) -> Void)? = nil) {
        
        // Try deleting the notes
        func tryUpdating(infoArray: [JSONCacheObject]) {
            
            // for each note parse it and try to delete it
            for tempInfo in infoArray where tempInfo.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: tempInfo.jsonData!) as? [Dictionary<String, Any>] {
                    
                    var array: [InterestsObject] = []
                    
                    for interest in dictionary {
                        
                        array.append(InterestsObject(fromCache: interest))
                    }
                    
                    func success(json: JSON, newToken: String?) {
                        
                        CachingHelper.deleteFromRealm(type: "interests-Post")
                        completion?()
                    }
                    
                    func failed(error: HATTableError) {
                        
                        errorCallback?(error)
                        CrashLoggerHelper.hatTableErrorLog(error: error)
                    }
                    
                    let unixTime = SurveyObject.createUnixTimeStamp()
                    array[0].dictionary.updateValue(unixTime, forKey: "unixTimeStamp")
                    HATAccountService.createTableValuev2(
                        token: userToken,
                        userDomain: userDomain,
                        source: Constants.HATTableName.Interests.source,
                        dataPath: Constants.HATTableName.Interests.name,
                        parameters: array[0].dictionary,
                        successCallback: success,
                        errorCallback: failed)
                }
            }
            
            completion?()
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "interests-Post", sync: tryUpdating)
    }
}
