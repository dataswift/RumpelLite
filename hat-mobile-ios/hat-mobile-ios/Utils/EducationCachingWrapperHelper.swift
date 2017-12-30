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

// MARK: Struct

internal struct EducationCachingWrapperHelper {

    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestEducation(userToken: String, userDomain: String, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([HATProfileEducationObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATProfileService.getEducationFromHAT(
                userDomain: userDomain,
                userToken: userToken,
                successCallback: { educationObject in
                
                    successRespond([educationObject], nil)
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
    static func getEducation(userToken: String, userDomain: String, cacheTypeID: String, successRespond: @escaping ([HATProfileEducationObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        EducationCachingWrapperHelper.checkForUnsyncedEducationToUpdate(
            userDomain: userDomain,
            userToken: userToken)
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.day,
            value: 1,
            networkRequest: EducationCachingWrapperHelper.requestEducation(userToken: userToken, userDomain: userDomain, failRespond: failRespond),
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
    static func postEducation(education: HATProfileEducationObject, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        CachingHelper.deleteFromRealm(type: "education")
        CachingHelper.deleteFromRealm(type: "education-Post")
        
        // creating note to be posted in cache
        let dictionary = education.toJSON()
        
        // adding note to be posted in cache
        do {
            
            guard let realm = RealmHelper.getRealm() else {
                
                return
            }
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [dictionary], type: "education", expiresIn: .day, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [dictionary], type: "education-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
            }
        } catch {
            
            print("adding to profile to update failed")
        }
        
        EducationCachingWrapperHelper.checkForUnsyncedEducationToUpdate(
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
    static func checkForUnsyncedEducationToUpdate(userDomain: String, userToken: String, completion: (() -> Void)? = nil, errorCallback: ((HATTableError) -> Void)? = nil) {
        
        // Try deleting the notes
        func tryUpdating(educationArray: [JSONCacheObject]) {
            
            // for each note parse it and try to delete it
            for tempEducation in educationArray where tempEducation.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: tempEducation.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let education = HATProfileEducationObject(fromCache: dictionary[0])
                    
                    func gotApplicationToken(appToken: String, newUserToken: String?) {
                        
                        HATProfileService.postEducationToHAT(
                            userDomain: userDomain,
                            userToken: userToken,
                            education: education,
                            successCallback: { _ in
                                
                                CachingHelper.deleteFromRealm(type: "education-Post")
                                completion?()
                            },
                            failCallback: { error in
                                
                                errorCallback?(error)
                            }
                        )
                    }
                    
                    func gotErrorWhenGettingApplicationToken(error: JSONParsingError) {
                        
                        CrashLoggerHelper.JSONParsingErrorLog(error: error)
                    }
                    
                    HATService.getApplicationTokenFor(
                        serviceName: Constants.ApplicationToken.Rumpel.name,
                        userDomain: userDomain,
                        token: userToken,
                        resource: Constants.ApplicationToken.Rumpel.source,
                        succesfulCallBack: gotApplicationToken,
                        failCallBack: gotErrorWhenGettingApplicationToken)
                }
            }
            
            completion?()
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "education-Post", sync: tryUpdating)
    }
}
