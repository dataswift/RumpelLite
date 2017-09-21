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

internal struct LocationsWrapperHelper {

    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATLocationsObject], String?) -> Void)
     */
    static func request(userToken: String, userDomain: String, locationsFromDate: Date?, locationsToDate: Date?, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([HATLocationsObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            func getLocationsFromTableID(_ tableID: NSNumber, newToken: String?) {
                
                // check dates if nil
                if locationsFromDate != nil && locationsToDate != nil {
                    
                    // parse them in Date type
                    let starttime = HATFormatterHelper.formatDateToEpoch(date: locationsFromDate!)
                    let endtime = HATFormatterHelper.formatDateToEpoch(date: locationsToDate!)
                    
                    // if they are not nil request the data from HAT
                    if starttime != nil && endtime != nil {
                        
                        let parameters: Dictionary<String, String> = [
                            "starttime": starttime!,
                            "endtime": endtime!,
                            "limit": "2000"]
                        
                        HATAccountService.getHatTableValues(
                            token: userToken,
                            userDomain: userDomain,
                            tableID: tableID,
                            parameters: parameters,
                            successCallback: { (json: [JSON], _) in
                            
                                var array: [HATLocationsObject] = []
                                
                                // add the returned data to array and pass it on to the completion function
                                for item in json {
                                    
                                    array.append(HATLocationsObject(dict: item.dictionaryValue))
                                }
                                successRespond(array, nil)
                            },
                            errorCallback: { error in
                        
                                // call failed completion function
                                CrashLoggerHelper.hatTableErrorLog(error: error)
                                failRespond(error)
                            }
                        )
                    }
                }
            }
            
            // check location table exists
            HATAccountService.checkHatTableExists(
                userDomain: userDomain,
                tableName: Constants.HATTableName.Location.name,
                sourceName: Constants.HATTableName.Location.source,
                authToken: userToken,
                successCallback: getLocationsFromTableID,
                errorCallback: { error in
                    
                    // call failed completion function
                    CrashLoggerHelper.hatTableErrorLog(error: error)
                    failRespond(error)
                }
            )
        }
    }
    
    // MARK: - Get system status
    
    /**
     Gets the system status from the hat
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter successRespond: A completion function of type ([HATLocationsObject], String?) -> Void
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     */
    static func getLocations(userToken: String, userDomain: String, locationsFromDate: Date?, locationsToDate: Date?, successRespond: @escaping ([HATLocationsObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        // construct the type of the cache to save
        let type: String
        
        if locationsToDate != nil && locationsFromDate != nil {
            
            type = "locations-\(locationsFromDate!)-\(locationsToDate!)"
        } else {
            
            type = "locations"
        }
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: type,
            expiresIn: Calendar.Component.hour,
            value: 1,
            networkRequest: LocationsWrapperHelper.request(
                userToken: userToken,
                userDomain: userDomain,
                locationsFromDate: locationsFromDate,
                locationsToDate: locationsToDate,
                failRespond: failRespond),
            completion: successRespond)
    }
}
