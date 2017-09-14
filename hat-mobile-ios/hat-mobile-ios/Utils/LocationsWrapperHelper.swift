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
     - parameter failRespond: A completion function of type (JSONParsingError) -> Void
     
     - returns: A function of type (([HATSystemStatusObject], String?) -> Void)
     */
    static func request(userToken: String, userDomain: String, locationsFromDate: Date?, locationsToDate: Date?, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([HATLocationsObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            func getLocationsFromTableID(_ tableID: NSNumber, newToken: String?) {
                
                if locationsFromDate != nil && locationsToDate != nil {
                    
                    let starttime = HATFormatterHelper.formatDateToEpoch(date: locationsFromDate!)
                    let endtime = HATFormatterHelper.formatDateToEpoch(date: locationsToDate!)
                    
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
                                
                                for item in json {
                                    
                                    array.append(HATLocationsObject(dict: item.dictionaryValue))
                                }
                                successRespond(array, nil)
                            },
                            errorCallback: { error in
                        
                                _ = CrashLoggerHelper.hatTableErrorLog(error: error)
                                failRespond(error)
                            }
                        )
                    }
                }
            }
            
            HATAccountService.checkHatTableExists(
                userDomain: userDomain,
                tableName: Constants.HATTableName.Location.name,
                sourceName: Constants.HATTableName.Location.source,
                authToken: userToken,
                successCallback: getLocationsFromTableID,
                errorCallback: { error in
                    
                    _ = CrashLoggerHelper.hatTableErrorLog(error: error)
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
     - parameter successRespond: A completion function of type ([HATSystemStatusObject], String?) -> Void
     - parameter failRespond: A completion function of type (JSONParsingError) -> Void
     */
    static func getLocations(userToken: String, userDomain: String, locationsFromDate: Date?, locationsToDate: Date?, successRespond: @escaping ([HATLocationsObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        let type: String
        
        if locationsToDate != nil && locationsFromDate != nil {
            
            type = "locations-\(locationsFromDate!)-\(locationsToDate!)"
        } else {
            
            type = "locations"
        }
        
        AsyncCachingHelper.decider(type: type,
                                   expiresIn: Calendar.Component.hour,
                                   value: 1,
                                   networkRequest: LocationsWrapperHelper.request(userToken: userToken, userDomain: userDomain, locationsFromDate: locationsFromDate, locationsToDate: locationsToDate, failRespond: failRespond),
                                   completion: successRespond)
    }
}
