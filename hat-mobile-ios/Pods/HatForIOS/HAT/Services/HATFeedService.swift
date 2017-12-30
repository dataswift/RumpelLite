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

import SwiftyJSON

// MARK: Struct

public struct HATFeedService {
    
    // MARK: - Get feed
    
    static public func getFeed(userDomain: String, userToken: String, parameters: Dictionary<String, Any> = [:], successCallback: @escaping ([HATFeedObject], String?) -> Void, failed: @escaping (HATTableError) -> Void) {
        
        func success(values: [JSON], newToken: String?) {
            
            var arrayToReturn: [HATFeedObject] = []
            for value in values {
                
                let dict = value["data"].dictionaryValue
                if let object: HATFeedObject = HATFeedObject.decode(from: dict) {
                    
                    arrayToReturn.append(object)
                }
            }
            
            successCallback(arrayToReturn, newToken)
        }
        
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            namespace: "she",
            scope: "feed",
            parameters: parameters,
            successCallback: success,
            errorCallback: failed)
    }
}
