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

internal struct CheckCache {
    
    // MARK: - Search for Unsynced Cache

    /**
     Checks for unsynced Cache for the specified cache Type
     
     - parameter type: The type of objects to query from Realm
     - parameter sync: A function returning an array of JSONCacheObject from Realm
     */
    static func searchForUnsyncedCache(type: String, sync: @escaping (([JSONCacheObject]) -> Void)) {
        
        // get objects from realm for the specified type
        guard let result = CachingHelper.getFromRealm(type: type) else {
            
            return
        }
        
        // if there are objects
        if !result.isEmpty {
            
            var dataArray: [JSONCacheObject] = []
            
            // iterate the array from ream and add it to the array to pass on the funtion else check expiry date in order to delete it
            for object in result where object.jsonData != nil {
                
                if object.expiryDate == nil || (object.expiryDate != nil && object.expiryDate! > Date()) {
                    
                    dataArray.append(object)
                } else if object.expiryDate != nil && object.expiryDate! < Date() {
                    
                    CachingHelper.deleteFromRealm(type: type)
                    break
                }
            }
            
            sync(dataArray)
        }
    }
}
