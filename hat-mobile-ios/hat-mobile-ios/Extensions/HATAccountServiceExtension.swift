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
import JWTDecode
import SwiftyJSON

// MARK: Extension

extension HATAccountService: UserCredentialsProtocol {
    
    // MARK: - User's settings
    
    /**
     Get the Market Access Token for the iOS data plug
     
     - returns: UserHATDomainAlias
     */
    static func theUserHATDomain() -> Constants.UserHATDomainAlias {
        
        if let hatDomain = KeychainHelper.getKeychainValue(key: Constants.Keychain.hatDomainKey) {
            
            return hatDomain
        }
        
        return ""
    }
    
    /**
     Gets user's token from keychain
     
     - returns: The token as a string
     */
    static func getUsersTokenFromKeychain() -> String {
        
        // check if the token has been saved in the keychain and return it. Else return an empty string
        if let token = KeychainHelper.getKeychainValue(key: "UserToken") {
            
            return token
        }
        
        return ""
    }
    
    // MARK: - Check if token is active
    
    /**
     Checks if token has expired
     
     - parameter token: The token to check if expired
     - parameter expiredCallBack: A function to execute if the token has expired
     - parameter tokenValidCallBack: A function to execute if the token is valid
     - parameter errorCallBack: A function to execute when something has gone wrong
     */
    static func checkIfTokenExpired(token: String, expiredCallBack: () -> Void, tokenValidCallBack: (String?) -> Void, errorCallBack: (String, String, String, @escaping () -> Void) -> Void) {
        
        do {
            
            let jwt = try decode(jwt: token)
            print(token)
            if jwt.expired {
                
                expiredCallBack()
            } else {
                
                tokenValidCallBack(token)
            }
        } catch {
            
            errorCallBack("Checking token expiry date failed, please log out and log in again", "Error", "OK", {})
        }
    }
    
    // MARK: - Verify domain
    
    /**
     Verify the domain if it's what we expect
     
     - parameter domain: The formated doamain
     
     - returns: Bool, true if the domain matches what we expect and false otherwise
     */
    static func verifyDomain(_ domain: String) -> Bool {
        
        if domain.hasSuffix("hubofallthings.net") || domain.hasSuffix("savy.io") || domain.hasSuffix("hubat.net") {
            
            return true
        }
        
        return false
    }
    
    // MARK: Create matchMe data bundle
    
    /**
     Creates a data bundle end point to get gather all the data needed for calculating profile completion rate
     
     - parameter success: A function to execute on success response. Returns true of false
     - parameter fail: A function to execute on failed response. Returns the error that occured
     */
    static func createMatchMeCompletion(success: @escaping (Bool) -> Void, fail: @escaping (HATTableError) -> Void) {
        
        if let url: URLConvertible = URL(string: "https://\(userDomain)/api/v2/data-bundle/datacompletion") {
            
            let parameters: Parameters = HATAccountService.constructJSON()

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
    static func getMatchMeCompletion(success: @escaping (Dictionary<String, JSON>) -> Void, fail: @escaping (HATTableError) -> Void) {
        
        if let url: URLConvertible = URL(string: "https://\(userDomain)/api/v2/data-bundle/datacompletion") {
            
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
    
    // MARK: - Create JSON for data bundle
    
    /**
     Constructs the JSON, as [String: Any] format, to pass in Alamofire request
     
     - returns: A [String: Any] array, suitable to pass in Alamofire request
     */
    static private func constructJSON() -> [String: Any] {
        
        return [
            "physicalactivities": [
                "endpoints": [
                    [
                    "endpoint": "rumpel/priorities/physicalactivities"
                    ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ],
            "dietary": [
                "endpoints": [
                [
                    "endpoint": "rumpel/priorities/dietary"
                ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ],
            "lifestyle": [
                "endpoints": [
                [
                    "endpoint": "rumpel/priorities/lifestyle"
                ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ],
            "happinessAndHealth": [
                "endpoints": [
                [
                    "endpoint": "rumpel/priorities/happinessandmentalhealth"
                ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ],
            "financialManagement": [
                "endpoints": [
                [
                    "endpoint": "rumpel/priorities/financialmanagement"
                ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ],
            "profileInfo": [
                "endpoints": [
                [
                    "endpoint": "rumpel/profile/profileinfo"
                ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ],
            "employmentStatus": [
                "endpoints": [
                [
                    "endpoint": "rumpel/profile/employmentstatus"
                ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ],
            "education": [
                "endpoints": [
                [
                    "endpoint": "rumpel/education"
                ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ],
            "livingInfo": [
                "endpoints": [
                [
                    "endpoint": "rumpel/profile/livinginfo"
                ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ],
            "interests": [
                "endpoints": [
                [
                    "endpoint": "rumpel/interests"
                ]
                ],
                "orderBy": "unixTimeStamp",
                "ordering": "descending",
                "limit": 1
            ]
        ]
    }

}
