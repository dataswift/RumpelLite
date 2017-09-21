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

// MARK: Struct

internal struct CachingHelper {
    
    // MARK: - Save to Realm

    /**
     Creates and saves an object into Realm
     
     - parameter dictionary: An array of Dictionaries of type <String, Any> representing the model we want
     - parameter objectType: A string to identify what type of object is that (note, locations etc)
     - parameter expiresIn: An optional Calendar.Component type indicating the period(Hour, Day, Month, etc) to expire
     - parameter value: An optional Int indicating the value of expiresIn. If value = 2 and expiresIn = .day then it will expire in 2 days
     */
    static func saveToRealm(dictionary: [Dictionary<String, Any>], objectType: String, expiresIn: Calendar.Component? = .day, value: Int? = 1) {
        
        // create new object and assign the values we want
        let jsonObject = JSONCacheObject(dictionary: dictionary, type: objectType, expiresIn: expiresIn, value: value)
        
        // Persist your data easily
        do {
            
            let realm = RealmHelper.getRealm()

            try realm.write {
                
                realm.add(jsonObject)
            }
        } catch {
            
            print("error saving to realm")
        }
    }
    
    // MARK: - Get from Realm
    
    /**
     Gets the objects of the specified type from Realm
     
     - parameter type: The type of object to get from Realm
     */
    static func getFromRealm(type: String) -> Results<JSONCacheObject> {
        
        let realm = RealmHelper.getRealm()
        // the filtering to use when quering Realm
        let predicate = NSPredicate(format: "type == %@", type as CVarArg)
        return realm.objects(JSONCacheObject.self).filter(predicate)
    }
    
    // MARK: - Delete from Realm
    
    /**
     Deletes from realm the objects of the specified type
     
     - parameter type: The type of objects to delete from Realm
     */
    static func deleteFromRealm(type: String) {
        
        do {
            
            let realm = RealmHelper.getRealm()
            let objects = CachingHelper.getFromRealm(type: type)

            try realm.write {
                
                realm.delete(objects)
            }
        } catch {
            
            print("error deleting from realm")
        }
    }
    
    // MARK: - Delete All Cache
    
    /**
     Deletes all cache (Realm + Hanake)
     */
    static func deleteCache() {
        
        do {
            
            // get and delete realm cache
            let realm = RealmHelper.getRealm()
            try realm.write {
                
                let objects = realm.objects(JSONCacheObject.self)
                realm.delete(objects)
            }
            
            // search through hanake directory for files to delete and delete them
            let appDir = "\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])/Caches/com.hpique.haneke/shared/"
            let filesArray = try FileManager.default.subpathsOfDirectory(atPath: appDir) as [String]
            for fileName in filesArray {
                
                let filePath = "\(appDir)/\(fileName)"
                try FileManager.default.removeItem(atPath: filePath)
            }
            
            // clear hanake
            HanakeHelper.clearCache()
        } catch {
            
            print("error emptying cache")
        }
    }
    
    // MARK: - Get Cache Size
    
    /**
     Returns the size of Realm cache
     
     - parameter type: The type of objects to query from Realm
     
     - returns: The Realm cache size as an Int in bytes
     */
    static func getRealmCacheSize(type: String) -> Int {
        
        let objects = getFromRealm(type: type)
        let mutableData: NSMutableData = NSMutableData()
        for object in objects where object.jsonData != nil {
            
            mutableData.append(NSKeyedArchiver.archivedData(withRootObject: object.jsonData!))
        }
        
        return (mutableData as Data).count
    }
    
    /**
     Returns the total size of Cache (Realm + Hanake)
     
     - returns: The total size of Cache (Realm + Hanake) as an Int in Bytes
     */
    static func getTotalCacheSize() -> Int {
        
        var totalSize = 0
        
        do {
            
            let appDir = "\(NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true)[0])/Caches/com.hpique.haneke/shared/"
            let filesArray = try FileManager.default.subpathsOfDirectory(atPath: appDir) as [String]
            var fileSize: UInt = 0
            
            for fileName in filesArray {
                
                let filePath = "\(appDir)/\(fileName)"
                let fileDictionary: NSDictionary = try FileManager.default.attributesOfItem(atPath: filePath) as NSDictionary
                fileSize += UInt(fileDictionary.fileSize())
            }
            
            totalSize += Int(fileSize)
        } catch {
            
            print("Error: \(error)")
        }
        
        return totalSize + CachingHelper.getRealmCacheSize(type: "systemStatus")
    }
}
