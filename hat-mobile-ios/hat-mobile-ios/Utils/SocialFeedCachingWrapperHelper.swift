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
            
            func tokenReceived(facebookToken: String, newUserToken: String?) {
                
                HATFacebookService.isFacebookDataPlugActive(
                    token: facebookToken,
                    successful: { _ in
                        
                        HATFacebookService.facebookDataPlug(
                            authToken: userToken,
                            userDomain: userDomain,
                            parameters: parameters,
                            success: { (array, newToken) in
                                
                                var arrayToReturn: [HATFacebookSocialFeedObject] = []
                                
                                for item in array {
                                    
                                    arrayToReturn.append(HATFacebookSocialFeedObject(from: item.dictionaryValue))
                                }
                                
                                successRespond(arrayToReturn, newToken)
                            }
                        )
                    },
                    failed: { _ in return })
            }
            
            // get Token for plugs
            HATFacebookService.getAppTokenForFacebook(
                token: userToken,
                userDomain: userDomain,
                successful: tokenReceived,
                failed: CrashLoggerHelper.JSONParsingErrorLogWithoutAlert)
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
            
            func tokenReceived(twitterToken: String, newUserToken: String?) {
                
                // check if twitter is active
                HATTwitterService.isTwitterDataPlugActive(
                    token: twitterToken,
                    successful: { _ in
                        
                        HATTwitterService.checkTwitterDataPlugTable(
                            authToken: userToken,
                            userDomain: userDomain,
                            parameters: parameters,
                            success: { (array, newToken) in
                        
                                var arrayToReturn: [HATTwitterSocialFeedObject] = []
                                
                                for item in array {
                                    
                                    arrayToReturn.append(HATTwitterSocialFeedObject(from: item.dictionaryValue))
                                }
                                
                                successRespond(arrayToReturn, newToken)
                            }
                        )
                    },
                    failed: { _ in return })
            }
            
            // get Token for plugs
            HATTwitterService.getAppTokenForTwitter(
                userDomain: userDomain,
                token: userToken,
                successful: tokenReceived,
                failed: CrashLoggerHelper.JSONParsingErrorLogWithoutAlert)
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
            
            // the returned array for the request
            func success(array: [JSON], renewedUserToken: String?) {
                
                if !array.isEmpty {
                    
                    // extract image
                    if let url = URL(string: array[0]["data"]["profile_picture"]["url"].stringValue) {
                        
                        // download image
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            
                            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                                let data = data, error == nil,
                                let image = UIImage(data: data)
                                else { return }
                            var profilePic = HATFacebookProfileImageObject()
                            profilePic.image = image
                            successRespond([profilePic], renewedUserToken)
                        }.resume()
                    }
                } else {
                    
                    var profilePic = HATFacebookProfileImageObject()
                    profilePic.image = UIImage(named: Constants.ImageNames.facebookImage)
                    successRespond([profilePic], renewedUserToken)
                }
            }
            
            // fetch facebook image
            HATFacebookService.fetchProfileFacebookPhoto(
                authToken: userToken,
                userDomain: userDomain,
                parameters: ["starttime": "0"],
                success: success)
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
