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

public struct HATDataDebitsService {
    
    // MARK: Get Data Debits

    /**
     Gets the available data debits for the user
     
     - parameter userToken: A String representing the user's token
     - parameter userDomain: A String representing the user's domain
     - parameter succesfulCallBack: A function of type ([DataDebitObject]) -> Void, executed on a successful result
     - parameter failCallBack: A function of type (DataPlugError) -> Void, executed on an unsuccessful result
     */
    public static func getAvailableDataDebits(userToken: String, userDomain: String, succesfulCallBack: @escaping ([DataDebitObject], String?) -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        let url: String = "http://\(userDomain)/dataDebit"
        
        let headers: Dictionary<String, String> = ["X-Auth-Token": userToken]
        
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.JSON,
            parameters: [:],
            headers: headers,
            completion: { (response: HATNetworkHelper.ResultType) -> Void in
            
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
                        
                        if statusCode == 200 {
                            
                            var returnValue: [DataDebitObject] = []
                            
                            for item in result.arrayValue {
                                
                                returnValue.append(DataDebitObject(dictionary: item.dictionaryValue))
                            }
                            
                            succesfulCallBack(returnValue, token)
                        } else {
                            
                            let message = NSLocalizedString("Server response was unexpected", comment: "")
                            failCallBack(.generalError(message, statusCode, nil))
                        }
                        
                    } else {
                        
                        let message = NSLocalizedString("Server response was unexpected", comment: "")
                        failCallBack(.generalError(message, statusCode, nil))
                    }
                }
            }
        )
    }
}
