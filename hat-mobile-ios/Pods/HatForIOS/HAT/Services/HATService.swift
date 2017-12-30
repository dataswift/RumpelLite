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

// MARK: Struct

/// A class about the methods concerning the HAT
public struct HATService {
    
    // MARK: - Application Token
    
    /**
     Gets the application level token from hat
     
     - parameter serviceName: The service name requesting the token
     - parameter resource: The resource for the token
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    public static func getApplicationTokenFor(serviceName: String, userDomain: String, token: String, resource: String, succesfulCallBack: @escaping (String, String?) -> Void, failCallBack: @escaping (JSONParsingError) -> Void) {
        
        // setup parameters and headers
        let parameters = ["name": serviceName, "resource": resource]
        let headers = [RequestHeaders.xAuthToken: token]
        
        // contruct the url
        let url = "https://\(userDomain)/users/application_token"
        
        // async request
        HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: parameters, headers: headers, completion: { (response: HATNetworkHelper.ResultType) -> Void in
            
            switch response {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                if error.localizedDescription == "The request timed out." {
                    
                    failCallBack(.noInternetConnection)
                } else {
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    failCallBack(.generalError(message, statusCode, error))
                }
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, let result, let token):
                
                if isSuccess {
                    
                    succesfulCallBack(result["accessToken"].stringValue, token)
                } else {
                    
                    failCallBack(.generalError(isSuccess.description, statusCode, nil))
                }
            }
        })
    }
    
    // MARK: - Get available HAT providers
    
    /**
     Fetches the available HAT providers
     */
    public static func getAvailableHATProviders(succesfulCallBack: @escaping ([HATProviderObject], String?) -> Void, failCallBack: @escaping (JSONParsingError) -> Void) {
        
        let url = "https://hatters.hubofallthings.com/api/products/hat"
        
        HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: [:], headers: [:], completion: {(response: HATNetworkHelper.ResultType) -> Void in
            
            switch response {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                if error.localizedDescription == "The request timed out." {
                    
                    failCallBack(.noInternetConnection)
                } else {
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    failCallBack(.generalError(message, statusCode, error))
                }
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, let result, let token):
                
                if isSuccess {
                    
                    let resultArray = result.arrayValue
                    var arrayToSendBack: [HATProviderObject] = []
                    for item in resultArray {
                        
                        arrayToSendBack.append(HATProviderObject(from: item.dictionaryValue))
                    }
                    
                    succesfulCallBack(arrayToSendBack, token)
                } else {
                    
                    let message = NSLocalizedString("Server response was unexpected", comment: "")
                    failCallBack(.generalError(message, statusCode, nil))
                }
            }
        })
    }
    
    /**
     Validates email address with the HAT
     */
    public static func validateEmailAddress(email: String, cluster: String, succesfulCallBack: @escaping (String, String?) -> Void, failCallBack: @escaping (JSONParsingError) -> Void) {
        
        let url = "https://hatters.hubofallthings.com/api/products/hat/validate-email"
        
        let parameters = ["email": email,
                          "cluster": cluster]
        
        HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: parameters, headers: [:], completion: {(response: HATNetworkHelper.ResultType) -> Void in
            
            switch response {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                if error.localizedDescription == "The request timed out." {
                    
                    failCallBack(.noInternetConnection)
                } else {
                    
                    let message = "Invalid Email. HAT with such email already exists"
                    failCallBack(.generalError(message, statusCode, error))
                }
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, _, let newToken):
                
                if isSuccess && statusCode == 200 {
                    
                    succesfulCallBack("valid email", newToken)
                } else if statusCode == 400 {
                    
                    let message = "Invalid Email. HAT with such email already exists"
                    failCallBack(.generalError(message, statusCode, nil))
                }
            }
        })
    }
    
    /**
     Validates HAT address with HAT
     */
    public static func validateHATAddress(address: String, cluster: String, succesfulCallBack: @escaping (String, String?) -> Void, failCallBack: @escaping (JSONParsingError) -> Void) {
        
        let url = "https://hatters.hubofallthings.com/api/products/hat/validate-hat"
        
        let parameters = ["address": address,
                          "cluster": cluster]
        
        HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: parameters, headers: [:], completion: {(response: HATNetworkHelper.ResultType) -> Void in
            
            switch response {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                if error.localizedDescription == "The request timed out." {
                    
                    failCallBack(.noInternetConnection)
                } else {
                    
                    let message = "Invalid address. HAT with such address already exists"
                    failCallBack(.generalError(message, statusCode, error))
                }
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, _, let newToken):
                
                if isSuccess && statusCode == 200 {
                    
                    succesfulCallBack("valid address", newToken)
                } else if statusCode == 400 {
                    
                    let message = "Invalid hat address. HAT with such address already exists"
                    failCallBack(.generalError(message, statusCode, nil))
                }
            }
        })
    }
    
    /**
     Validates HAT address with HAT
     */
    public static func confirmHATPurchase(purchaseModel: PurchaseObject, succesfulCallBack: @escaping (String, String?) -> Void, failCallBack: @escaping (JSONParsingError) -> Void) {
        
        let url = "https://hatters.hubofallthings.com/api/products/hat/purchase"
        
        let body = PurchaseObject.encode(from: purchaseModel)!
        
        HATNetworkHelper.asynchronousRequest(url, method: .post, encoding: Alamofire.JSONEncoding.default, contentType: ContentType.JSON, parameters: body, headers: [:], completion: {(response: HATNetworkHelper.ResultType) -> Void in
            
            switch response {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                if error.localizedDescription == "The request timed out." {
                    
                    failCallBack(.noInternetConnection)
                } else {
                    
                    let message = "Invalid address. HAT with such address already exists"
                    failCallBack(.generalError(message, statusCode, error))
                }
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, let result, let newToken):
                
                if isSuccess && statusCode == 200 {
                    
                    succesfulCallBack("purchase ok", newToken)
                } else {
                    
                    let message = result["message"].stringValue
                    failCallBack(.generalError(message, statusCode, nil))
                }
            }
        })
    }
    
    // MARK: - Get system status
    
    /**
     Fetches the available HAT providers
     */
    public static func getSystemStatus(userDomain: String, authToken: String, completion: @escaping ([HATSystemStatusObject], String?) -> Void, failCallBack: @escaping (JSONParsingError) -> Void) {
        
        let url = "https://\(userDomain)/api/v2/system/status"
        let headers = ["X-Auth-Token": authToken]
        
        HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: [:], headers: headers, completion: {(response: HATNetworkHelper.ResultType) -> Void in
            
            switch response {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                if error.localizedDescription == "The request timed out." {
                    
                    failCallBack(.noInternetConnection)
                } else {
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    failCallBack(.generalError(message, statusCode, error))
                }
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, let result, let token):
                
                if isSuccess {
                    
                    let resultArray = result.arrayValue
                    var arrayToSendBack: [HATSystemStatusObject] = []
                    for item in resultArray {
                        
                        arrayToSendBack.append(HATSystemStatusObject(from: item.dictionaryValue))
                    }
                    
                    completion(arrayToSendBack, token)
                } else {
                    
                    let message = NSLocalizedString("Server response was unexpected", comment: "")
                    failCallBack(.generalError(message, statusCode, nil))
                }
            }
        })
    }
}
