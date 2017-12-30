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
import RealmSwift
import SwiftyJSON

// MARK: Class

/// The sync data helper class
internal class SyncDataHelper: UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The data sync delegate variable
    weak var dataSyncDelegate: DataSyncDelegate?
    
    // MARK: - Sync functions
    
    /**
     Gets the last successful sync count from preferences
     
     - returns: Int
     */
    class func getSuccessfulSyncCount() -> Int {
        
        // returns an integer if the key existed, or 0 if not.
        return UserDefaults.standard.integer(forKey: Constants.Preferences.successfulSyncCount)
    }
    
    /**
     Gets the last successful sync count from preferences
     
     - returns: The date of last successful sync. Optional
     */
    class func getLastSuccessfulSyncDate() -> Date! {
        
        // get standard user defaults
        let preferences = UserDefaults.standard
        
        // search for the particular key, if found return it
        if let successfulSyncDate: Date = preferences.object(forKey: Constants.Preferences.successfulSyncDate) as? Date {
            
            return successfulSyncDate
        }
        
        return nil
    }
    
    /**
     Check if we have any DataPoints to sync
     
     NB:
     Since queries in Realm are lazy, performing paginating behavior isn’t necessary at all,
     as Realm will only load objects from the results of the query once they are explicitly accessed.
     
     - returns: A Bool indicating if we have data to sync or not
     */
    func checkNextBlockToSync() -> Bool {
        
        RealmHelper.removeSyncedLocationsFromDB()
        RealmHelper().checkSyncingLocations()

        guard let realm = RealmHelper.getRealm() else {
            
            return false
        }

        // predicate to check for nil sync field
        let predicate = NSPredicate(format: "lastSynced == %@")
        let sortProperties = [SortDescriptor(keyPath: "dateAdded", ascending: true)]
        let results: Results<DataPoint> = realm.objects(DataPoint.self).filter(predicate).sorted(by: sortProperties)
            
        var theBlockDataPoints: [DataPoint] = []
        
        for dataPoint in results where dataPoint.longitude != 0 && dataPoint.latitude != 0 && dataPoint.verticalAccuracy != 0 && !dataPoint.isInvalidated {
            
            // append
            theBlockDataPoints.append(dataPoint)
        }
        
        // only sync if we have data
        if theBlockDataPoints.count > 10 {
            
            do {
                
                try realm.write {
                    
                    for dataPoint in theBlockDataPoints {
                        
                        dataPoint.syncStatus = "syncing"
                        dataPoint.dateSyncStatusChanged = Int(Date().timeIntervalSince1970)
                    }
                }
            } catch let error {
                
                print(error)
            }
            
            self.syncDataItems(theBlockDataPoints, completion: { result, newToken in
                
                if result {
                    
                    do {
                        
                        try realm.write {
                            
                            for dataPoint in theBlockDataPoints {
                                
                                dataPoint.syncStatus = "synced"
                                dataPoint.dateSyncStatusChanged = Int(Date().timeIntervalSince1970)
                            }
                        }
                    } catch let error {
                        
                        print(error)
                    }
                    
                    KeychainHelper.setKeychainValue(key: newToken, value: Constants.Keychain.userToken)
                }
            })
            return true
        }
        
        return false
    }
    
    /**
     Sync with HAT, a block of DataPoints
     
     - parameter dataPoints: The data points to sync
     */
    func syncDataItems(_ dataPoints: [DataPoint], completion: ((Bool, String?) -> Void)? = nil) {

        // inform user
        if self.dataSyncDelegate != nil {
            
            self.dataSyncDelegate?.onDataSyncFeedback(true, message: "OK")
        }
        
        var locations: [HATLocationsV2DataObject] = []
        
        for datapoint in dataPoints {
            
            var tempLocation = HATLocationsV2DataObject()
            
            tempLocation.latitude = Float(datapoint.latitude)
            tempLocation.longitude = Float(datapoint.longitude)
            tempLocation.altitude = Float(datapoint.altitude)
            tempLocation.verticalAccuracy = Float(datapoint.verticalAccuracy)
            tempLocation.horizontalAccuracy = Float(datapoint.horizontalAccuracy)
            tempLocation.speed = Float(datapoint.speed)
            tempLocation.floor = datapoint.floor
            tempLocation.course = Float(datapoint.course)
            tempLocation.dateCreated = datapoint.dateCreated
            tempLocation.dateCreatedLocal = datapoint.dateCreatedLocal
            
            locations.append(tempLocation)
        }
        
        HATLocationService.syncLocationsToHAT(
            userDomain: userDomain,
            userToken: userToken,
            locations: locations,
            completion: completion)
    }
}
