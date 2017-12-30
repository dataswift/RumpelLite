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

import RealmSwift

// MARK: Class

/// The DataPoint object representation
public class DataPoint: Object {
    
    // MARK: - Variables
    
    @objc dynamic var latitude: Double = 0
    @objc dynamic var longitude: Double = 0
    @objc dynamic var horizontalAccuracy: Double = -1
    @objc dynamic var verticalAccuracy: Double = -1
    @objc dynamic var dateCreated: Int = -1
    @objc dynamic var dateCreatedLocal: String = ""
    @objc dynamic var speed: Double = -1
    @objc dynamic var altitude: Double = -1
    @objc dynamic var course: Double = -1
    @objc dynamic var floor: Int = -1
    
    /// The added point date of the point
    @objc dynamic var dateAdded: Date = Date()
    /// The last sync date of the point
    @objc dynamic var lastSynced: Date?
    @objc dynamic var syncStatus: String = "unsynced"
    @objc dynamic var dateSyncStatusChanged: Int = -1
}
