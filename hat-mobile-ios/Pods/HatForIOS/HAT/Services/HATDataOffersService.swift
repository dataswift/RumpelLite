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

public struct HATDataOffersService {
    
    // MARK: - Get available data offers
    
    /**
     Gets the available data plugs for the user to enable
     
     - parameter succesfulCallBack: A function of type ([HATDataPlugObject]) -> Void, executed on a successful result
     - parameter failCallBack: A function of type (Void) -> Void, executed on an unsuccessful result
     */
    public static func getAvailableDataOffers(applicationToken: String, merchants: [String]?, succesfulCallBack: @escaping ([DataOfferObject], String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let mutableURL: NSMutableString = "http://databuyer.hubofallthings.com/api/v1/offersWithClaims"
        
        for (index, merchant) in (merchants?.enumerated())! {
            
            if index == 0 {
                
                mutableURL.append("?")
            } else {
                
                mutableURL.append("&")
            }
            
            mutableURL.append("merchant=\(merchant)")
        }
        
        let url: String = mutableURL as String
        let headers: Dictionary<String, String> = ["X-Auth-Token": applicationToken]
        
        HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: [:], headers: headers, completion: { (response: HATNetworkHelper.ResultType) -> Void in
            
            switch response {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                let message = NSLocalizedString("Server responded with error", comment: "")
                failCallBack(.generalError(message, statusCode, error))
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, let result, let token):
                
                if isSuccess {
                    
                    var returnValue: [DataOfferObject] = []
                    
                    for item in result.arrayValue {
                        
                        returnValue.append(DataOfferObject(dictionary: item.dictionaryValue))
                    }
                    
                    succesfulCallBack(returnValue, token)
                } else {
                    
                    let message = NSLocalizedString("Server response was unexpected", comment: "")
                    failCallBack(.generalError(message, statusCode, nil))
                }
            }
        })
    }
    
    // MARK: - Claim offer
    
    /**
     Gets the available data plugs for the user to enable
     
     - parameter succesfulCallBack: A function of type ([HATDataPlugObject]) -> Void, executed on a successful result
     - parameter failCallBack: A function of type (Void) -> Void, executed on an unsuccessful result
     */
    public static func claimOffer(applicationToken: String, offerID: String, succesfulCallBack: @escaping (String, String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let url: String = "http://databuyer.hubofallthings.com/api/v1/offer/\(offerID)/claim"
        let headers: Dictionary<String, String> = ["X-Auth-Token": applicationToken]
        
        HATNetworkHelper.asynchronousRequest(url, method: .get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.JSON, parameters: [:], headers: headers, completion: { (response: HATNetworkHelper.ResultType) -> Void in
            
            switch response {
                
            // in case of error call the failCallBack
            case .error(let error, let statusCode):
                
                let message = NSLocalizedString("Server responded with error", comment: "")
                failCallBack(.generalError(message, statusCode, error))
            // in case of success call the succesfulCallBack
            case .isSuccess(let isSuccess, let statusCode, let result, let token):
                
                if isSuccess {
                    
                    let dictionaryResponse = result.dictionaryValue
                    
                    if let claimed = dictionaryResponse["status"]?.stringValue {
                        
                        succesfulCallBack(claimed, token)
                    } else {
                        
                        let message = NSLocalizedString("Server response was unexpected", comment: "")
                        failCallBack(.generalError(message, statusCode, nil))
                    }
                } else {
                    
                    let message = NSLocalizedString("Server response was unexpected", comment: "")
                    failCallBack(.generalError(message, statusCode, nil))
                }
            }
        })
    }
    
    // MARK: - Redeem offer
    
    /**
     Redeems cash offer
     
     - parameter appToken: The databuyer app token
     - parameter succesfulCallBack: A function to execute on successful response returning the server message and the renewed user's token
     - parameter failCallBack: A function to execute on failed response returning the error
     */
    public static func redeemOffer(appToken: String, succesfulCallBack: @escaping (String, String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let url = "https://databuyer.hubofallthings.com/api/v1/user/redeem/cash"
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.JSON,
            parameters: ["X-Auth-Token": appToken],
            headers: [:],
            completion: { (response: HATNetworkHelper.ResultType) -> Void in
                
                switch response {
                    
                case .error(let error, let statusCode):
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    failCallBack(.generalError(message, statusCode, error))
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if statusCode == 200 && isSuccess {
                        
                        let dictionaryResponse = result.dictionaryValue
                        if let message = dictionaryResponse["message"]?.stringValue {
                            
                            succesfulCallBack(message, token)
                        }
                    }
                }
        }
        )
    }
    
    // MARK: - Get Merchants
    
    /**
     Gets available merchants from HAT
     
     - parameter userToken: The users token
     - parameter userDomain: The user's domain name
     - parameter succesfulCallBack: A function to execute on successful response returning the merchants array and the renewed user's token
     - parameter failCallBack: A function to execute on failed response returning the error
     */
    public static func getMerchants(userToken: String, userDomain: String, succesfulCallBack: @escaping ([String], String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let url = "https://\(userDomain)/api/v2/data/dex/databuyer"
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.JSON,
            parameters: ["take": 1, "orderBy": "date", "ordering": "descending"],
            headers: ["X-Auth-Token": userToken],
            completion: { (response: HATNetworkHelper.ResultType) -> Void in
                
                switch response {
                    
                case .error(let error, let statusCode):
                    
                    let message = NSLocalizedString("Server responded with error", comment: "")
                    failCallBack(.generalError(message, statusCode, error))
                case .isSuccess(let isSuccess, let statusCode, let result, let token):
                    
                    if statusCode == 200 && isSuccess && !result.arrayValue.isEmpty {
                        
                        let dictionaryResponse = result.arrayValue[0].dictionaryValue
                        if let tempDictionary = dictionaryResponse["data"]?.dictionaryValue {
                            
                            if let merchants = tempDictionary["merchants"]?.arrayValue {
                                
                                var arrayToReturn: [String] = []
                                for merchant in merchants {
                                    
                                    if let merchantString = merchant.string {
                                        
                                        arrayToReturn.append(merchantString)
                                    }
                                }
                                succesfulCallBack(arrayToReturn, token)
                            }
                        }
                    } else if statusCode == 200 && isSuccess && result.arrayValue.isEmpty {
                        
                        succesfulCallBack([], token)
                    } else if statusCode == 401 {
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        failCallBack(.generalError(message, statusCode, nil))
                    }
                }
        }
        )
    }
}
