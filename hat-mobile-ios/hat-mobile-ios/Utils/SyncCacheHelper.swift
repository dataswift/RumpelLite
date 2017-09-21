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

    static func searchForUnsyncedCache(type: String, sync: @escaping (([JSONCacheObject]) -> Void)) {
        
        let result = CachingHelper.getFromRealm(type: type)
        if !result.isEmpty {
            
            var dataArray: [JSONCacheObject] = []
            
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
