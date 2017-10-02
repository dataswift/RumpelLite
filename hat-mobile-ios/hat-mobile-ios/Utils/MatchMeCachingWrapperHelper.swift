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

internal struct MatchMeCachingWrapperHelper {

    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestMatchMeObject(userToken: String, userDomain: String, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([MatchMeObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATAccountService.getMatchMeCompletion(
                success: { dictionary in
            
                    var matchMe: MatchMeObject = MatchMeObject()
                    
                    if let dietary = dictionary["dietary"]?.arrayValue {
                        
                        if !dietary.isEmpty {
                            
                            if let array = dietary[0].dictionary?["data"]?["array"].array {
                                
                                var tempDict: [Dictionary<String, Any>] = []
                                for item in array {
                                    
                                    let object = SurveyObject(from: item)
                                    tempDict.append(object.toJSON())
                                }
                                
                                matchMe.dictionary.updateValue(tempDict, forKey: "dietary")
                            }
                        }
                    }
                    
                    if let profileInfo = dictionary["profileInfo"]?.arrayValue {
                        
                        if !profileInfo.isEmpty {
                            
                            if let array = profileInfo[0].dictionary {
                                
                                let object = HATProfileInfo(from: JSON(array))
                                matchMe.dictionary.updateValue(object.toJSON(), forKey: "profileInfo")
                            }
                        }
                    }
                    
                    if let employmentStatus = dictionary["employmentStatus"]?.arrayValue {
                        
                        if !employmentStatus.isEmpty {
                            
                            if let array = employmentStatus[0].dictionary {
                                
                                let object = HATEmployementStatusObject(from: JSON(array))
                                matchMe.dictionary.updateValue(object.toJSON(), forKey: "employmentStatus")
                            }
                        }
                    }
                    
                    if let happinessAndHealth = dictionary["happinessAndHealth"]?.arrayValue {
                        
                        if !happinessAndHealth.isEmpty {
                            
                            if let array = happinessAndHealth[0].dictionary?["data"]?["array"].array {
                                
                                var tempDict: [Dictionary<String, Any>] = []
                                for item in array {
                                    
                                    let object = SurveyObject(from: item)
                                    tempDict.append(object.toJSON())
                                }
                                
                                matchMe.dictionary.updateValue(tempDict, forKey: "happinessAndHealth")
                            }
                        }
                    }
                    
                    if let livingInfo = dictionary["livingInfo"]?.arrayValue {
                        
                        if !livingInfo.isEmpty {
                            
                            if let array = livingInfo[0].dictionary {
                                
                                let object = HATLivingInfoObject(from: JSON(array))
                                matchMe.dictionary.updateValue(object.toJSON(), forKey: "livingInfo")
                            }
                        }
                    }
                    
                    if let physicalActivities = dictionary["physicalactivities"]?.arrayValue {
                        
                        if !physicalActivities.isEmpty {
                            
                            if let array = physicalActivities[0].dictionary?["data"]?["array"].array {
                                
                                var tempDict: [Dictionary<String, Any>] = []
                                for item in array {
                                    
                                    let object = SurveyObject(from: item)
                                    tempDict.append(object.toJSON())
                                }
                                
                                matchMe.dictionary.updateValue(tempDict, forKey: "physicalactivities")
                            }
                        }
                    }
                    
                    if let education = dictionary["education"]?.arrayValue {
                        
                        if !education.isEmpty {
                            
                            if let array = education[0].dictionary {
                                
                                let object = HATProfileEducationObject(from: JSON(array))
                                matchMe.dictionary.updateValue(object.toJSON(), forKey: "education")
                            }
                        }
                    }
                    
                    if let interests = dictionary["interests"]?.arrayValue {
                        
                        if !interests.isEmpty {
                            
                            if let array = interests[0].dictionary {
                                
                                let object = InterestsObject(from: array)
                                matchMe.dictionary.updateValue(object.toJSON(), forKey: "interests")
                            }
                        }
                    }
                    
                    if let financialManagement = dictionary["financialManagement"]?.arrayValue {
                        
                        if !financialManagement.isEmpty {
                            
                            if let array = financialManagement[0].dictionary?["data"]?["array"].array {
                                
                                var tempDict: [Dictionary<String, Any>] = []
                                for item in array {
                                    
                                    let object = SurveyObject(from: item)
                                    tempDict.append(object.toJSON())
                                }
                                
                                matchMe.dictionary.updateValue(tempDict, forKey: "financialManagement")
                            }
                        }
                    }
                    
                    if let lifestyle = dictionary["lifestyle"]?.arrayValue {
                        
                        if !lifestyle.isEmpty {
                            
                            if let array = lifestyle[0].dictionary?["data"]?["array"].array {
                                
                                var tempDict: [Dictionary<String, Any>] = []
                                for item in array {
                                    
                                    let object = SurveyObject(from: item)
                                    tempDict.append(object.toJSON())
                                }
                                
                                matchMe.dictionary.updateValue(tempDict, forKey: "lifestyle")
                            }
                        }
                    }
                    
                    successRespond([matchMe], nil)
                },
                fail: failRespond)
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
    static func getMatchMeObject(userToken: String, userDomain: String, cacheTypeID: String, successRespond: @escaping ([MatchMeObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.day,
            value: 1,
            networkRequest: MatchMeCachingWrapperHelper.requestMatchMeObject(userToken: userToken, userDomain: userDomain, failRespond: failRespond),
            completion: successRespond
        )
    }
}
