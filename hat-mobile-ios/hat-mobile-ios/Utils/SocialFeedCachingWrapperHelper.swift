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

internal struct SocialFeedCachingWrapperHelper {
    
    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestFacebook(userToken: String, userDomain: String, parameters: Dictionary<String, String>, failRespond: @escaping (JSONParsingError) -> Void) -> ((@escaping (([HATFacebookSocialFeedObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATFacebookService.getFacebookData(
                authToken: userToken,
                userDomain: userDomain,
                parameters: parameters,
                successCallback: successRespond,
                errorCallback: { error in
                    
                    failRespond(.generalError(error.localizedDescription, nil, error))
                }
            )
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
    static func getFacebookFeed(userToken: String, userDomain: String, cacheTypeID: String, parameters: Dictionary<String, String>, successRespond: @escaping ([HATFacebookSocialFeedObject], String?) -> Void, failRespond: @escaping (JSONParsingError) -> Void) {
        
        let type = cacheTypeID + parameters.description
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: type,
            expiresIn: Calendar.Component.hour,
            value: 1,
            networkRequest: SocialFeedCachingWrapperHelper.requestFacebook(
                userToken: userToken,
                userDomain: userDomain,
                parameters: parameters,
                failRespond: failRespond),
            completion: successRespond)
    }
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestTwitter(userToken: String, userDomain: String, parameters: Dictionary<String, String>, failRespond: @escaping (JSONParsingError) -> Void) -> ((@escaping (([HATTwitterSocialFeedObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATTwitterService.fetchTweetsV2(
                authToken: userToken,
                userDomain: userDomain,
                parameters: parameters,
                successCallback: successRespond,
                errorCallback: { error in
                    
                    failRespond(.generalError(error.localizedDescription, nil, error))
                }
            )
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
    static func getTwitterFeed(userToken: String, userDomain: String, cacheTypeID: String, parameters: Dictionary<String, String>, successRespond: @escaping ([HATTwitterSocialFeedObject], String?) -> Void, failRespond: @escaping (JSONParsingError) -> Void) {
        
        let type = cacheTypeID + parameters.description
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: type,
            expiresIn: Calendar.Component.hour,
            value: 1,
            networkRequest: SocialFeedCachingWrapperHelper.requestTwitter(
                userToken: userToken,
                userDomain: userDomain,
                parameters: parameters,
                failRespond: failRespond),
            completion: successRespond)
    }
    
    static func requestFacebookProfilePicture(userToken: String, userDomain: String) -> ((@escaping (([HATFacebookProfileImageObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATFacebookService.fetchProfileFacebookPhotoV2(
                authToken: userToken,
                userDomain: userDomain,
                parameters: ["take": "1",
                             "orderBy": "date"],
                successCallback: successRespond,
                errorCallback: { _ in return}
            )
        }
    }
    
    static func getFacebookProfilePicture(userToken: String, userDomain: String, cacheTypeID: String, successRespond: @escaping ([HATFacebookProfileImageObject], String?) -> Void) {
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.day,
            value: 1,
            networkRequest: SocialFeedCachingWrapperHelper.requestFacebookProfilePicture(
                userToken: userToken,
                userDomain: userDomain),
            completion: successRespond)
    }

}
