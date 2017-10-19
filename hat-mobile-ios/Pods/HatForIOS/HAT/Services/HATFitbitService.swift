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

import Alamofire
import SwiftyJSON

// MARK: Struct

public struct HATFitbitService {
    
    // MARK: - Get Fitbit Data
    
    /**
     Gets all the endpoints from the hat and searches for the fitbit specific ones
     
     - parameter successCallback: A function returning an array of Strings, The endpoints found, and the new token
     - parameter errorCallback: A function returning the error occured
     */
    public static func getFitbitEndpoints(successCallback: @escaping ([String], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        let url = "https://dex.hubofallthings.com/stats/available-data"
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.JSON,
            parameters: [:],
            headers: [:],
            completion: { response in
                
                switch response {
                    
                case .error(let error, let statusCode):
                    
                    if error.localizedDescription == "The request timed out." {
                        
                        errorCallback(.noInternetConnection)
                    } else {
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        errorCallback(.generalError(message, statusCode, error))
                    }
                case .isSuccess(let isSuccess, _, let result, let token):
                    
                    if isSuccess {
                        
                        if let array = result.array {
                            
                            for item in array where item["namespace"] == "fitbit" {
                                
                                var arraytoReturn: [String] = []
                                
                                let tempArray = item["endpoints"].arrayValue
                                for tempItem in tempArray {
                                    
                                    arraytoReturn.append(tempItem["endpoint"].stringValue)
                                }
                                
                                successCallback(arraytoReturn, token)
                            }
                        } else {
                            
                            errorCallback(.noValuesFound)
                        }
                    }
                }
            }
        )
    }
    
    public static func getSleep(userDomain: String, userToken: String, successCallback: @escaping ([HATFitbitSleepObject], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        HATFitbitService.getGeneric(
            userDomain: userDomain,
            userToken: userToken,
            namespace: "fitbit",
            scope: "sleep",
            parameters: ["take": "1"],
            successCallback: successCallback,
            errorCallback: errorCallback)
    }
    
    private static func getGeneric<Object: HATObject>(userDomain: String, userToken: String, namespace: String, scope: String, parameters: Dictionary<String, String>, successCallback: @escaping ([Object], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        func gotResponse(json: [JSON], renewedToken: String?) {
            
            // if we have values return them
            if !json.isEmpty {
                
                var arrayToReturn: [Object] = []
                
                for item in json {
                    
                    if let object: Object = Object.decode(from: item["data"].dictionaryValue) {
                        
                        arrayToReturn.append(object)
                    } else {
                        
                        print("error parsing json")
                    }
                }
                
                successCallback(arrayToReturn, renewedToken)
            } else {
                
                errorCallback(.noValuesFound)
            }
        }
        
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            namespace: namespace,
            scope: scope,
            parameters: parameters,
            successCallback: gotResponse,
            errorCallback: errorCallback)
    }
    
    public static func getWeight(userDomain: String, userToken: String, successCallback: @escaping ([HATFitbitWeightObject], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        HATFitbitService.getGeneric(
            userDomain: userDomain,
            userToken: userToken,
            namespace: "fitbit",
            scope: "weight",
            parameters: ["take": "1"],
            successCallback: successCallback,
            errorCallback: errorCallback)
    }
    
    public static func getProfile(userDomain: String, userToken: String, successCallback: @escaping ([HATFitbitProfileObject], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        HATFitbitService.getGeneric(
            userDomain: userDomain,
            userToken: userToken,
            namespace: "fitbit",
            scope: "profile",
            parameters: ["take": "1"],
            successCallback: successCallback,
            errorCallback: errorCallback)
    }
    
    public static func getDailyActivity(userDomain: String, userToken: String, successCallback: @escaping ([HATFitbitDailyActivityObject], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        HATFitbitService.getGeneric(
            userDomain: userDomain,
            userToken: userToken,
            namespace: "fitbit",
            scope: "activity/day/summary",
            parameters: ["take": "1"],
            successCallback: successCallback,
            errorCallback: errorCallback)
    }
    
    public static func getLifetimeStats(userDomain: String, userToken: String, successCallback: @escaping ([HATFitbitStatsObject], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        HATFitbitService.getGeneric(
            userDomain: userDomain,
            userToken: userToken,
            namespace: "fitbit",
            scope: "lifetime/stats",
            parameters: ["take": "1"],
            successCallback: successCallback,
            errorCallback: errorCallback)
    }
    
    public static func getActivity(userDomain: String, userToken: String, successCallback: @escaping ([HATFitbitActivityObject], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        HATFitbitService.getGeneric(
            userDomain: userDomain,
            userToken: userToken,
            namespace: "fitbit",
            scope: "activity",
            parameters: ["take": "1"],
            successCallback: successCallback,
            errorCallback: errorCallback)
    }
    
    public static func checkIfFitbitIsEnabled(userDomain: String, userToken: String, successCallback: @escaping (Bool) -> Void, errorCallback: @escaping (JSONParsingError) -> Void) {
        
        func gotToken(fitbitToken: String, newUserToken: String?) {
            
            // construct the url, set parameters and headers for the request
            let url = Fitbit.statusURL
            let parameters: Dictionary<String, String> = [:]
            let headers = [RequestHeaders.xAuthToken: fitbitToken]
            
            // make the request
            HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: parameters, headers: headers, completion: {(response: HATNetworkHelper.ResultType) -> Void in
                
                // act upon response
                switch response {
                    
                case .isSuccess(_, let statusCode, _, _):
                    
                    if statusCode == 200 {
                        
                        successCallback(true)
                    } else {
                        
                        successCallback(false)
                    }
                    
                // inform user that there was an error
                case .error(let error, let statusCode):
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    errorCallback(.generalError(message, statusCode, error))
                }
            })
        }
        
        HATFitbitService.getApplicationTokenForFitbit(
            userDomain: userDomain,
            userToken: userToken,
            successCallback: gotToken,
            errorCallback: errorCallback)
    }
    
    public static func getApplicationTokenForFitbit(userDomain: String, userToken: String, successCallback: @escaping (String, String?) -> Void, errorCallback: @escaping (JSONParsingError) -> Void) {
        
        HATService.getApplicationTokenFor(
            serviceName: Fitbit.serviceName,
            userDomain: userDomain,
            token: userToken,
            resource: Fitbit.dataPlugURL,
            succesfulCallBack: successCallback,
            failCallBack: errorCallback)
    }
}
