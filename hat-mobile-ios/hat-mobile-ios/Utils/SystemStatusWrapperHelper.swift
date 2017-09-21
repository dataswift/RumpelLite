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

// MARK: Struct

internal struct SystemStatusWrapperHelper {
    
    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter failRespond: A completion function of type (JSONParsingError) -> Void
     
     - returns: A function of type (([HATSystemStatusObject], String?) -> Void)
     */
    static func request(userToken: String, userDomain: String, failRespond: @escaping (JSONParsingError) -> Void) -> ((@escaping (([HATSystemStatusObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            // get system status from hat
            HATService.getSystemStatus(
                userDomain: userDomain,
                authToken: userToken,
                completion: successRespond,
                failCallBack: failRespond)
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
    static func getSystemStatus(userToken: String, userDomain: String, successRespond: @escaping ([HATSystemStatusObject], String?) -> Void, failRespond: @escaping (JSONParsingError) -> Void) {
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(type: "systemStatus",
                                   networkRequest: SystemStatusWrapperHelper.request(userToken: userToken, userDomain: userDomain, failRespond: failRespond),
                                   completion: successRespond)
    }
}
