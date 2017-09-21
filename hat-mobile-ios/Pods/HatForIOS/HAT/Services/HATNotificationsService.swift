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

public struct HATNotificationsService {

    // MARK: - Get hat notifications
    
    /**
     Gets values from a particular table in use with v1 API
     
     - parameter appToken: The token in String format
     - parameter successCallback: A callback called when successful of type @escaping ([NotificationObject]) -> Void
     - parameter errorCallback: A callback called when failed of type @escaping (Void) -> Void)
     */
    public static func getHATNotifications(appToken: String, successCallback: @escaping ([NotificationObject], String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // form the url
        let url = "https://dex.hubofallthings.com/api/notices"
        
        // create parameters and headers
        let headers = [RequestHeaders.xAuthToken: appToken]
        
        // make the request
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .get,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.JSON,
            parameters: [:],
            headers: headers,
            completion: { (response: HATNetworkHelper.ResultType) -> Void in
            
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
                            
                            var arrayToReturn: [NotificationObject] = []
                            for notification in array {
                                
                                arrayToReturn.append(NotificationObject(dictionary: notification.dictionaryValue))
                            }
                            successCallback(arrayToReturn, token)
                        } else {
                            
                            errorCallback(.noValuesFound)
                        }
                    }
                }
            }
        )
    }
    
    // MARK: - Mark notification as read
    
    /**
     Gets values from a particular table in use with v1 API
     
     - parameter appToken: The token in String format
     - parameter successCallback: A callback called when successful of type @escaping ([NotificationObject]) -> Void
     - parameter errorCallback: A callback called when failed of type @escaping (Void) -> Void)
     */
    public static func markNotificationAsRead(appToken: String, notificationID: String, successCallback: @escaping (Bool, String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // form the url
        let url = "https://dex.hubofallthings.com/api/notices/\(notificationID)/read"
        
        // create parameters and headers
        let headers = [RequestHeaders.xAuthToken: appToken]
        
        // make the request
        HATNetworkHelper.asynchronousRequest(
            url,
            method: .put,
            encoding: Alamofire.URLEncoding.default,
            contentType: ContentType.JSON,
            parameters: [:],
            headers: headers,
            completion: { (response: HATNetworkHelper.ResultType) -> Void in
                
                switch response {
                    
                case .error(let error, let statusCode):
                    
                    if error.localizedDescription == "The request timed out." {
                        
                        errorCallback(.noInternetConnection)
                    } else {
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        errorCallback(.generalError(message, statusCode, error))
                    }
                case .isSuccess(let isSuccess, let statusCode, _, let token):
                    
                    if isSuccess {
                        
                        successCallback(true, token)
                    } else {
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        errorCallback(.generalError(message, statusCode, nil))
                    }
                }
            }
        )
    }
}
