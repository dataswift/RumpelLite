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
import HatForIOS
import SwiftyJSON

extension HATFitbitService {

    // MARK: - Create JSON for data bundle
    
    /**
     Constructs the JSON, as [String: Any] format, to pass in Alamofire request
     
     - returns: A [String: Any] array, suitable to pass in Alamofire request
     */
    static private func constructJSON() -> [String: Any] {
        
        return [
            "weight": [
                "endpoints": [
                    [
                        "endpoint": "fitbit/weight"
                    ]
                ],
                "orderBy": "date",
                "ordering": "descending",
                "limit": 1
            ],
            "sleep": [
                "endpoints": [
                    [
                        "endpoint": "fitbit/sleep"
                    ]
                ],
                "orderBy": "startTime",
                "ordering": "descending",
                "limit": 1
            ],
            "profile": [
                "endpoints": [
                    [
                        "endpoint": "fitbit/profile"
                    ]
                ],
                "limit": 1
            ],
            "activity": [
                "endpoints": [
                    [
                        "endpoint": "fitbit/activity"
                    ]
                ],
                "orderBy": "startTime",
                "ordering": "descending",
                "limit": 1
            ],
            "activity/day/summary": [
                "endpoints": [
                    [
                        "endpoint": "fitbit/activity/day/summary"
                    ]
                ],
                "limit": 1
            ]
        ]
    }
    
    public static func createBundleWithAllData(userDomain: String, userToken: String, success: @escaping (Bool) -> Void, fail: @escaping (HATTableError) -> Void) {
        
        if let url: URLConvertible = URL(string: "https://\(userDomain)/api/v2/data-bundle/fitbitall") {
            
            let parameters: Parameters = HATFitbitService.constructJSON()
            
            Alamofire.request(
                url,
                method: .post,
                parameters: parameters,
                encoding: Alamofire.JSONEncoding.default,
                headers: ["x-auth-token": userToken]).responseJSON(completionHandler: { response in
                    
                    switch response.result {
                    case .success:
                        
                        if response.response?.statusCode == 201 || response.response?.statusCode == 200 {
                            
                            success(true)
                        } else {
                            
                            success(false)
                        }
                    case .failure(let error):
                        
                        fail(HATTableError.generalError("", nil, error))
                    }
                }
            )
        }
    }
    
    // MARK: - Get matchMe data bundle
    
    /**
     Fetches the data bundle for the calculation of the profile completeness
     
     - parameter success: A function to execute on success response. Returns the dictionary, JSON, of that endpoint
     - parameter fail: A function to execute on failed response. Returns the error that occured
     */
    static func getFitbitData(userDomain: String, userToken: String, success: @escaping (Dictionary<String, JSON>) -> Void, fail: @escaping (HATTableError) -> Void) {
        
        if let url: URLConvertible = URL(string: "https://\(userDomain)/api/v2/data-bundle/fitbitall") {
            
            Alamofire.request(
                url,
                method: .get,
                parameters: nil,
                encoding: Alamofire.JSONEncoding.default,
                headers: ["x-auth-token": userToken]).responseJSON(completionHandler: { response in
                    
                    switch response.result {
                    case .success:
                        
                        if let value = response.result.value {
                            
                            let json = JSON(value)
                            success(json.dictionaryValue)
                        } else {
                            
                            fail(HATTableError.generalError("json creation failed", nil, nil))
                        }
                    case .failure(let error):
                        
                        fail(HATTableError.generalError("", nil, error))
                    }
                }
            )
        }
    }
}
