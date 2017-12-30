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
import RealmSwift

// MARK: Class

internal class AsyncCachingHelper<T: HatApiType> {
    
    // MARK: - Decide source
    
    /**
     Decides where to get the data from. Cache of Connect to the server.
     
     - parameter type: A string to identify what type of object is that (note, locations etc)
     - parameter expiresIn: An optional Calendar.Component type indicating the period(Hour, Day, Month, etc) to expire
     - parameter value: An optional Int indicating the value of expiresIn. If value = 2 and expiresIn = .day then it will expire in 2 days
     - parameter networkRequest: A function of type ([T], String?) returning an array of cache objects and the new Token executed in network request
     - parameter completion: A function of type ([T], String?) returning an array of cache objects and the new Token executed upon completion
     */
    class func decider(type: String, expiresIn: Calendar.Component = .day, value: Int = 1, networkRequest: ((@escaping (([T], String?) -> Void)) -> Void)?, completion: (([T], String?) -> Void)?) {
        
        func asyncCacheResponse(data: [T], token: String?) {
            
            var tempArray: [Dictionary<String, Any>] = []
            
            for dict in data {
                
                tempArray.append(dict.toJSON())
            }
            
            if !tempArray.isEmpty {
                
                CachingHelper.saveToRealm(dictionary: tempArray, objectType: type, expiresIn: expiresIn, value: value)
            }
            
            completion?(data, token)
        }
        
        // get Realm Cache
        guard let result = CachingHelper.getFromRealm(type: type) else {
            
            return
        }
        
        // if no result perform network fetch, else parse the Realm Results and return that
        if result.isEmpty {
            
            networkRequest?(asyncCacheResponse)
        } else {
            
            let cached = AsyncCachingHelper.makeNewApiObjectFromCache(cached: result, type: type)
            
            if cached.isEmpty {
                
                networkRequest?(asyncCacheResponse)
            } else {
                
                completion?(cached, nil)
            }
        }
    }
    
    // MARK: - Create new Object from Cache
    
    /**
     Creates a cache object from the objects return from Realm
     
     - parameter cached: The results returned from Realm
     - parameter type: A string to identify what type of object is that (note, locations etc)
     
     - returns: An array of cache objects or an empty array if nothing found
     */
    class func makeNewApiObjectFromCache(cached: Results<JSONCacheObject>, type: String) -> [T] {
        
        var arrayToReturn: [T] = []
        
        // for each object in the results from Realm try to parse it and add it to the array to be returned
        for object in cached where object.jsonData != nil {
            
            if let array = NSKeyedUnarchiver.unarchiveObject(with: object.jsonData!) as? [Dictionary<String, Any>] {
                
                for element in array {
                    
                    // Check expiry date of the record in order to invalidated it and delete it
                    if object.expiryDate == nil || (object.expiryDate != nil && object.expiryDate! > Date()) {
                        
                        let cachedObject = T(fromCache: element)
                        arrayToReturn.append(cachedObject)
                    } else if object.expiryDate != nil && object.expiryDate! < Date() && Reachability.isConnectedToNetwork() {
                        
                        CachingHelper.deleteFromRealm(type: type)
                        break
                    }
                }
            }
        }
        
        return arrayToReturn
    }
    
}
