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

internal struct ProfileCachingHelper {
    
    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestProfile(userToken: String, userDomain: String, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([HATProfileObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATPhataService.getProfileFromHAT(
                userDomain: userDomain,
                userToken: userToken,
                successCallback: { profile in
                
                    successRespond([profile], nil)
                },
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
    static func getProfile(userToken: String, userDomain: String, cacheTypeID: String, successRespond: @escaping ([HATProfileObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        ProfileCachingHelper.checkForUnsyncedProfileToUpdate(
            userDomain: userDomain,
            userToken: userToken)
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.day,
            value: 1,
            networkRequest: ProfileCachingHelper.requestProfile(
                userToken: userToken,
                userDomain: userDomain,
                failRespond: failRespond),
            completion: successRespond)
    }
    
    // MARK: - Post Note
    
    /**
     Posts a note
     
     - parameter note: The note to be posted
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     */
    static func postProfile(profile: HATProfileObject, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        CachingHelper.deleteFromRealm(type: "profile")
        CachingHelper.deleteFromRealm(type: "profile-Post")
        
        // creating note to be posted in cache
        let dictionary = profile.toJSON()
        
        // adding note to be posted in cache
        do {
            
            let realm = RealmHelper.getRealm()
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [dictionary], type: "profile", expiresIn: .day, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [dictionary], type: "profile-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
            }
        } catch {
            
            print("adding to profile to update failed")
        }
        
        ProfileCachingHelper.checkForUnsyncedProfileToUpdate(
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
    static func checkForUnsyncedProfileToUpdate(userDomain: String, userToken: String, completion: (() -> Void)? = nil, errorCallback: ((HATTableError) -> Void)? = nil) {
        
        // Try deleting the notes
        func tryUpdating(profiles: [JSONCacheObject]) {
            
            // for each note parse it and try to delete it
            for tempProfile in profiles where tempProfile.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: tempProfile.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let profile = HATProfileObject(fromCache: dictionary[0])
                    func tableExists(dict: Dictionary<String, Any>, renewedUserToken: String?) {
                        
                        HATPhataService.postProfile(
                            userDomain: userDomain,
                            userToken: userToken,
                            hatProfile: profile,
                            successCallBack: {
                                
                                CachingHelper.deleteFromRealm(type: "profile-Post")
                                completion?()
                            },
                            errorCallback: {error in
                                
                                errorCallback?(error)
                                CrashLoggerHelper.hatTableErrorLog(error: error)
                            }
                        )
                    }
                    
                    HATAccountService.checkHatTableExistsForUploading(
                        userDomain: userDomain,
                        tableName: Constants.HATTableName.Profile.name,
                        sourceName: Constants.HATTableName.Profile.source,
                        authToken: userToken,
                        successCallback: tableExists,
                        errorCallback: {error in
                            
                            errorCallback?(error)
                            CrashLoggerHelper.hatTableErrorLog(error: error)
                        }
                    )
                }
            }
            
            completion?()
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "profile-Post", sync: tryUpdating)
    }
}
