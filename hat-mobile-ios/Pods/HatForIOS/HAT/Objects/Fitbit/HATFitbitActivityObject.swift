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

import UIKit

public struct HATFitbitActivityObject: HATObject {

    public var logId: Int = 0
    public var steps: Int = 0
    public var logType: String = ""
    public var tcxLink: String = ""
    public var calories: Int = 0
    public var duration: Int = 0
    public var startTime: String = ""
    public var activityName: String = ""
    public var lastModified: String = ""
    public var activityLevel: [HATFitbitActivityLevelObject] = []
    public var elevationGain: Int = 0
    public var heartRateLink: String = ""
    public var activeDuration: Int = 0
    public var activityTypeId: Int = 0
    public var heartRateZones: [HATFitbitActivityHeartRateZoneObject] = []
    public var averageHeartRate: Int = 0
    public var originalDuration: Int = 0
    public var originalStartTime: String = ""
    public var manualValuesSpecified: HATFitbitActivityManualValuesObject = HATFitbitActivityManualValuesObject()
}
