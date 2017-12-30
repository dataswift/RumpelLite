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
    static func request(userToken: String, userDomain: String, locationsFromDate: Date? = Date().startOfDate(), locationsToDate: Date? = Date().endOfDate()!, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([HATLocationsV2Object], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            func combinatorCreated(result: Bool, newUserToken: String?) {
                
                HATAccountService.getBetweenLocationCombinator(
                    userDomain: userDomain,
                    userToken: userToken,
                    successCallback: { locations, newToken in
                        
                        var arrayToReturn = locations
                        // predicate to check for nil sync field
                        let predicate = NSPredicate(format: "lastSynced == %@")
                        
                        let locationsDB = RealmHelper.getResults(predicate)!
                        for location in locationsDB where location.dateCreated <= Date.endOfDateInUnixTimeStape(date: locationsToDate!)! && location.dateCreated >= Date.startOfDateInUnixTimeStape(date: locationsFromDate!) {
                            
                            var tempLoc = HATLocationsV2Object()
                            tempLoc.data.latitude = Float(location.latitude)
                            tempLoc.data.longitude = Float(location.longitude)
                            tempLoc.data.dateCreated = location.dateCreated
                            
                            arrayToReturn.append(tempLoc)
                        }
                        
                        successRespond(arrayToReturn, newToken)
                    },
                    failCallback: { _ in
                        
                        failRespond(.generalError("", nil, nil))
                    }
                )
            }
            
            let startOfDay = Date.startOfDateInUnixTimeStape(date: locationsFromDate!)
            let endOfDay = Date.endOfDateInUnixTimeStape(date: locationsToDate!)
            
            HATAccountService.createBetweenLocationCombinator(
                userDomain: userDomain,
                userToken: userToken,
                combinatorName: "locationsfilter",
                fieldToFilter: "dateCreated",
                lowerValue: startOfDay,
                upperValue: endOfDay!,
                successCallback: combinatorCreated,
                failCallback: { _ in
                    
                    failRespond(.generalError("", nil, nil))
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
    static func getLocations(userToken: String, userDomain: String, locationsFromDate: Date?, locationsToDate: Date?, successRespond: @escaping ([HATLocationsV2Object], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
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
