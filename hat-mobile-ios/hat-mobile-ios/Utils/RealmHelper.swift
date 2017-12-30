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

import CoreLocation
import HatForIOS
import RealmSwift

// MARK: Class

// swiftlint:disable force_try
// swiftlint:disable force_cast
/// Static Realm Helper methods
public class RealmHelper {
    
    // MARK: - Typealiases
    
    typealias Latitude = Double
    typealias Longitude = Double
    typealias Accuracy = Double
    
    // MARK: - Get realm
    
    /**
     Get the default Realm DB representation
     
     - returns: The default Realm object
     */
    class func getRealm() -> Realm? {
        
        // Get the default Realm
        do {
           
            return try Realm()
        } catch {
            
            return nil
        }
        
        return nil
    }
    
    // MARK: - Add data
    
    /**
     Adds data in form of lat/lng
     
     - parameter latitude: The latitude value of the point
     - parameter longitude: The longitude value of the point
     - parameter accuracy: The accuracy of the point
     
     - returns: current item count
     */
    class func addData(_ location: CLLocation) -> Int {
        
        // Get the default Realm
        guard let realm = self.getRealm() else {
            
            return 0
        }
        
        // data
        let dataPoint = DataPoint()
        dataPoint.latitude = location.coordinate.latitude
        dataPoint.longitude = location.coordinate.longitude
        dataPoint.verticalAccuracy = location.verticalAccuracy
        dataPoint.dateCreated = Int(Date().timeIntervalSince1970)
        dataPoint.dateCreatedLocal = HATFormatterHelper.formatDateToISO(date: Date())
        dataPoint.course = location.course
        dataPoint.speed = location.speed
        dataPoint.horizontalAccuracy = location.horizontalAccuracy
        dataPoint.altitude = location.altitude
        dataPoint.dateAdded = Date()
        
        // Persist your data easily
        try! realm.write {
            
            realm.add(dataPoint)
        }
        
        // get count
        let dataPoints = realm.objects(DataPoint.self)
        
        return dataPoints.count
    }
    
    // MARK: - Update realm
    
    /**
     Takes an array of DataPoints and updates the lastUpdated field
     
     - parameter dataPoints:  Array of DataPoints
     - parameter lastUpdated: Date of last sync
     */
    class func updateData(_ dataPoints: [DataPoint], lastUpdated: Date) {
        
        // Get the default Realm
        guard let realm = self.getRealm() else {
            
            return
        }
        
        // iterate and update
        try! realm.write {
            
            // iterate over ResultSet and update
            for dataPoint in dataPoints {
                
                dataPoint.lastSynced = lastUpdated
            }
        }
    }
    
    // MARK: - Delete from realm
    
    /**
     Purge all data for a predicate
     
     - parameter predicate: The predicate used to filter the data
     
     - returns: always true if sucessful
     */
    class func purge(_ predicate: NSPredicate?) -> Bool {
        
        // Get the default Realm
        guard let realm: Realm = self.getRealm() else {
            
            return false
        }
        
        try! realm.write {
            
            // check if predicate is nil, if it is delete everything
            guard let unwrappedPredicate = predicate else {
                
                realm.deleteAll()
                
                return
            }
            
            // filter the data using the predicate
            let list: Results<DataPoint> = realm.objects(DataPoint.self).filter(unwrappedPredicate)
            realm.delete(list)
        }
        
        return true
    }
   
    class func removeSyncedLocationsFromDB(_ realm: Realm? = nil) {
        
        guard let realm: Realm = RealmHelper.getRealm() else {
            
            return
        }
        
        let sortProperties = [SortDescriptor(keyPath: "dateCreated", ascending: false)]
        let dbLocations: Results<DataPoint> = realm.objects(DataPoint.self).sorted(by: sortProperties)
        
        do {
            
            try realm.write {
                
                for location in dbLocations where !location.isInvalidated && location.syncStatus == "synced" {
                    
                    realm.delete(location)
                }
            }
        } catch let error as NSError {
            
            print(error)
            print("error deleting objects")
        }
    }
    
    func checkSyncingLocations() {
        
        guard let realm: Realm = RealmHelper.getRealm() else {
            
            return
        }
        
        let sortProperties = [SortDescriptor(keyPath: "dateCreated", ascending: false)]
        let dbLocations: Results<DataPoint> = realm.objects(DataPoint.self).sorted(by: sortProperties)
        var locationsToUpdate: [DataPoint] = []
        
        for location in dbLocations where location.dateSyncStatusChanged > 0  && location.syncStatus == "syncing" {
            
            let syncingDate = Date(timeIntervalSince1970: Double(location.dateSyncStatusChanged))
            let currentDate = Date()
            guard let minutes = Calendar.current.dateComponents([.minute], from: syncingDate, to: currentDate).minute else {
                
                return
            }
            
            if minutes > 5 {
                
                do {
                    
                    try realm.write {
                        
                        location.syncStatus = "unsynced"
                        location.dateSyncStatusChanged = -1
                        locationsToUpdate.append(location)
                        
                        realm.add(location)
                    }
                } catch let error as NSError {
                    
                    print(error)
                }
            }
        }
    }
    
    class func checkLocationForSync(location: DataPoint) -> DataPoint? {
        
        if location.syncStatus == "syncing" {
            
            let syncingDate = Date(timeIntervalSince1970: Double(location.dateSyncStatusChanged))
            let currentDate = Date()
            guard let minutes = Calendar.current.dateComponents([.minute], from: syncingDate, to: currentDate).minute else {
                
                return nil
            }
            
            if minutes > 5 {
                
                location.syncStatus = "unsynced"
                location.dateSyncStatusChanged = -1
                
                return location
            }
        } else if location.syncStatus == "unsynced" {
            
            return location
        }
        
        return nil
    }
    
    // MARK: - Get results from realm
    
    /**
     Gets a list of results from the current Realm DB object and filters by the predicate
     
     - parameter predicate: The predicate used to filter the data
     
     - returns: list of datapoints
     */
    class func getResults(_ predicate: NSPredicate) -> Results<DataPoint>? {
        
        // Get the default Realm
        guard let realm: Realm = self.getRealm() else {
            
            return nil
        }
        
        let sortProperties = [SortDescriptor(keyPath: "dateAdded", ascending: true)]
        
        return realm.objects(DataPoint.self).filter(predicate).sorted(by: sortProperties)
    }
    
    /**
     Gets the most recent DataPoint
     
     - returns: A DataPoint object
     */
    class func getLastDataPoint() -> DataPoint! {
        
        // Get the default Realm
        guard let realm: Realm = self.getRealm() else {
            
            return nil
        }
        
        return realm.objects(DataPoint.self).last
    }
    
    class func migrateDB() {
        
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 1,
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if oldSchemaVersion == 0 {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                    migration.enumerateObjects(ofType: DataPoint.className()) { oldObject, newObject in
                        // combine name fields into a single field
                        newObject!["latitude"] = oldObject!["lat"] as! Double
                        newObject!["longitude"] = oldObject!["lng"] as! Double
                        newObject!["horizontalAccuracy"] = oldObject!["accuracy"] as! Double
                        newObject!["verticalAccuracy"] = -1
                        newObject!["dateCreated"] = -1
                        newObject!["dateCreatedLocal"] = ""
                        newObject!["speed"] = -1
                        newObject!["altitude"] = -1
                        newObject!["course"] = -1
                        newObject!["syncStatus"] = "synced"
                        newObject!["dateSyncStatusChanged"] = Date().timeIntervalSince1970
                        newObject!["floor"] = 0
                    }
                }
        })
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
        
        // Now that we've told Realm how to handle the schema change, opening the file
        // will automatically perform the migration
         _ = try! Realm()
    }
    // swiftlint:enable force_try
    // swiftlint:enable force_cast
}
