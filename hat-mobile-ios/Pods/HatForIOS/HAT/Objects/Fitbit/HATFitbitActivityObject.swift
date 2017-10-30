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

// MARK: Struct

public struct HATFitbitActivityObject: HATObject {
    
    // MARK: - Variables
    
    public var logId: Int = 0
    public var steps: Int?
    public var logType: String = ""
    public var tcxLink: String?
    public var calories: Int = 0
    public var duration: Int64 = 0
    public var startTime: String = ""
    public var activityName: String = ""
    public var lastModified: String = ""
    public var activityLevel: [HATFitbitActivityLevelObject] = []
    public var elevationGain: Float?
    public var heartRateLink: String?
    public var activeDuration: Int = 0
    public var activityTypeId: Int = 0
    public var heartRateZones: [HATFitbitActivityHeartRateZoneObject]?
    public var averageHeartRate: Int?
    public var originalDuration: Int = 0
    public var originalStartTime: String = ""
    public var manualValuesSpecified: HATFitbitActivityManualValuesObject = HATFitbitActivityManualValuesObject()
}
