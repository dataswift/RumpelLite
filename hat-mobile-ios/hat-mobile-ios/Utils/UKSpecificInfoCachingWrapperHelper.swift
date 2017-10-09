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

internal struct UKSpecificInfoCachingWrapperHelper {

    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestUKSpecificInfo(userToken: String, userDomain: String, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([UKSpecificInfo], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATAccountService.getHatTableValuesv2(
                token: userToken,
                userDomain: userDomain,
                namespace: Constants.HATTableName.UKSpecificInfo.source,
                scope: Constants.HATTableName.UKSpecificInfo.name,
                parameters: ["take": "1", "orderBy": "unixTimeStamp", "ordering": "descending"],
                successCallback: { (json, newToken) in
            
                    var array: [UKSpecificInfo] = []
                    
                    for item in json {
                        
                        array.append(UKSpecificInfo(from: item))
                    }
                    
                    successRespond(array, newToken)
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
    static func getUKSpecificInfo(userToken: String, userDomain: String, cacheTypeID: String, successRespond: @escaping ([UKSpecificInfo], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        UKSpecificInfoCachingWrapperHelper.checkForUnsyncedUKSpecificInfoToUpdate(
            userDomain: userDomain,
            userToken: userToken)
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.day,
            value: 1,
            networkRequest: UKSpecificInfoCachingWrapperHelper.requestUKSpecificInfo(userToken: userToken, userDomain: userDomain, failRespond: failRespond),
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
    static func postUKSpecificInfo(ukSpecificInfo: UKSpecificInfo, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        CachingHelper.deleteFromRealm(type: "ukSpecificInfo")
        CachingHelper.deleteFromRealm(type: "ukSpecificInfo-Post")
        
        // creating note to be posted in cache
        let dictionary = ukSpecificInfo.toJSON()
        
        // adding note to be posted in cache
        do {
            
            let realm = RealmHelper.getRealm()
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [dictionary], type: "ukSpecificInfo", expiresIn: .day, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [dictionary], type: "ukSpecificInfo-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
            }
        } catch {
            
            print("adding to profile to update failed")
        }
        
        UKSpecificInfoCachingWrapperHelper.checkForUnsyncedUKSpecificInfoToUpdate(
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
    static func checkForUnsyncedUKSpecificInfoToUpdate(userDomain: String, userToken: String, completion: (() -> Void)? = nil, errorCallback: ((HATTableError) -> Void)? = nil) {
        
        // Try deleting the notes
        func tryUpdating(ukSpecificInfo: [JSONCacheObject]) {
            
            // for each note parse it and try to delete it
            for tempUKInfo in ukSpecificInfo where tempUKInfo.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: tempUKInfo.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let ukSpecific = UKSpecificInfo(fromCache: dictionary[0])
                    let json = ukSpecific.toJSON()
                    
                    HATAccountService.createTableValuev2(
                        token: userToken,
                        userDomain: userDomain,
                        source: Constants.HATTableName.UKSpecificInfo.source,
                        dataPath: Constants.HATTableName.UKSpecificInfo.name,
                        parameters: json,
                        successCallback: { (_, _) in
                    
                            CachingHelper.deleteFromRealm(type: "ukSpecificInfo-Post")
                            completion?()
                        },
                        errorCallback: { error in
                    
                            errorCallback?(error)
                        }
                    )
                }
            }
            
            completion?()
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "ukSpecificInfo-Post", sync: tryUpdating)
    }
    
}
