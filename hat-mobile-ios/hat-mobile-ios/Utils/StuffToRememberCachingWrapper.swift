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

internal struct StuffToRememberCachingWrapper {

    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestStuffToRememberObject(userToken: String, userDomain: String, cacheTypeID: String, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([StuffToRememberObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            func success(stuffToRemember: [StuffToRememberObject], newToken: String?) {
                
                if !stuffToRemember.isEmpty {
                        
                    successRespond(stuffToRemember, newToken)
                } else {
                    
                    successRespond([], newToken)
                }
            }
            
            func failed(error: HATTableError) {
                
                failRespond(error)
                CrashLoggerHelper.hatTableErrorLog(error: error)
            }
            
            HATProfileService.getStuffToRememberFromHAT(
                userDomain: userDomain,
                userToken: userToken,
                successCallback: success,
                failCallback: failRespond)
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
    static func getStuffToRememberObject(userToken: String, userDomain: String, cacheTypeID: String, successRespond: @escaping ([StuffToRememberObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        StuffToRememberCachingWrapper.checkForUnsyncedStuffToRememberObjectToUpdate(
            userDomain: userDomain,
            userToken: userToken,
            completion: { },
            errorCallback: { _ in return })
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.day,
            value: 1,
            networkRequest: StuffToRememberCachingWrapper.requestStuffToRememberObject(
                userToken: userToken,
                userDomain: userDomain,
                cacheTypeID: cacheTypeID,
                failRespond: failRespond),
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
    static func postStuffToRememberObject(stuffToRememberObject: StuffToRememberObject, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        CachingHelper.deleteFromRealm(type: "stuffToRememberObject")
        CachingHelper.deleteFromRealm(type: "stuffToRememberObject-Post")
        
        // adding note to be posted in cache
        do {
            
            let realm = RealmHelper.getRealm()
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [stuffToRememberObject.toJSON()], type: "stuffToRememberObject", expiresIn: .day, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [stuffToRememberObject.toJSON()], type: "stuffToRememberObject-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
            }
        } catch {
            
            print("adding to profile to update failed")
        }
        
        StuffToRememberCachingWrapper.checkForUnsyncedStuffToRememberObjectToUpdate(
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
    static func checkForUnsyncedStuffToRememberObjectToUpdate(userDomain: String, userToken: String, completion: (() -> Void)? = nil, errorCallback: ((HATTableError) -> Void)? = nil) {
        
        // Try deleting the notes
        func tryUpdating(infoArray: [JSONCacheObject]) {
            
            for object in infoArray where object.jsonData != nil {
                
                if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: object.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let stuffToRememberObject = StuffToRememberObject(fromCache: dictionary[0])
                    
                    func valueCreated(result: StuffToRememberObject, renewedUserToken: String?) {
                        
                        do {
                            let realm = RealmHelper.getRealm()
                            try realm.write {
                                
                                realm.delete(object)
                            }
                        } catch {
                            
                            print("error deleting from realm")
                        }
                        completion?()
                    }
                    
                    func failed(error: HATTableError) {
                        
                        errorCallback?(error)
                        CrashLoggerHelper.hatTableErrorLog(error: error)
                    }
                    
                    HATProfileService.postStuffToRememberToHAT(
                        userDomain: userDomain,
                        userToken: userToken,
                        stuffToRemember: stuffToRememberObject,
                        successCallback: valueCreated,
                        failCallback: failed
                    )
                }
            }
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "stuffToRememberObject-Post", sync: tryUpdating)
    }
}
