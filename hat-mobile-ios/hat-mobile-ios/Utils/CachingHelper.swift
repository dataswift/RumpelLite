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
import SwiftyJSON

internal class CachingHelper: NSObject {

    class func saveToRealm(dictionary: [Dictionary<String, Any>], objectType: String, expiresIn: Calendar.Component? = .day, value: Int? = 1) {
        
        let realm = RealmHelper.getRealm()
        
        let jsonObject = JSONCacheObject()
        jsonObject.jsonData = NSKeyedArchiver.archivedData(withRootObject: dictionary)
        jsonObject.dateAdded = Date()
        jsonObject.type = objectType
        jsonObject.uniqueKey = UUID().uuidString
        
        if expiresIn != nil && value != nil {
            
            let calendar = Calendar.current
            jsonObject.expiryDate = calendar.date(byAdding: expiresIn!, value: value!, to: jsonObject.dateAdded!)
        }
        
        // Persist your data easily
        do {
            
            try realm.write {
                
                realm.add(jsonObject)
            }
        } catch {
            
            print("error saving to realm")
        }
    }
    
    class func getFromRealm(type: String) -> Results<JSONCacheObject> {
        
        let realm = RealmHelper.getRealm()
        let predicate = NSPredicate(format: "type == %@", type as CVarArg)
        return realm.objects(JSONCacheObject.self).filter(predicate)
    }
    
    class func deleteFromRealm(type: String) {
        
        let realm = RealmHelper.getRealm()
        let objects = CachingHelper.getFromRealm(type: type)
        
        do {
            
            try realm.write {
                
                realm.delete(objects)
            }
        } catch {
            
            print("error deleting from realm")
        }
    }
    
    class func getRealmCacheSize(type: String) -> Int {
        
        let objects = getFromRealm(type: type)
        let mutableData: NSMutableData = NSMutableData()
        for object in objects {
            
            mutableData.append(NSKeyedArchiver.archivedData(withRootObject: object.jsonData!))
        }
        
        return (mutableData as Data).count
    }
}

internal class AsyncCachingHelper<T: HatApiType> {
    
    class func decider(type: String, expiresIn: Calendar.Component? = .day, value: Int? = 1, networkRequest: (@escaping (([T], String?) -> Void)) -> Void, completion: @escaping ([T], String?) -> Void) {
        
        func asyncCacheResponse(data: [T], token: String?) {
            
            var array: [Dictionary<String, Any>] = []
            for dict in data {
                
                array.append(dict.toJSON())
            }
            
            CachingHelper.saveToRealm(dictionary: array, objectType: type, expiresIn: expiresIn, value: value)
            completion(data, token)
        }
        
        let result = CachingHelper.getFromRealm(type: type)
        if result.isEmpty {
            
            networkRequest(asyncCacheResponse)
        } else {
            
            let cached = AsyncCachingHelper.makeNewApiObjectFromCache(cached: result, type: type)
            completion(cached, nil)
        }
    }
    
    class func makeNewApiObjectFromCache(cached: Results<JSONCacheObject>, type: String) -> [T] {
        
        var arrayToReturn: [T] = []

        for object in cached where object.jsonData != nil {
            
            if let array = NSKeyedUnarchiver.unarchiveObject(with: object.jsonData!) as? [Dictionary<String, Any>] {
                
                for element in array {
                    
                    if object.expiryDate == nil || (object.expiryDate != nil && object.expiryDate! > Date()) {
                        
                        let cachedObject = T(fromCache: element)
                        arrayToReturn.append(cachedObject)
                    } else if object.expiryDate != nil && object.expiryDate! < Date() {
                        
                        CachingHelper.deleteFromRealm(type: type)
                    }
                }
            }
        }
        
        return arrayToReturn
    }

}
