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

public struct HATFitbitSleepObject: HATObject {
    
    // MARK: - Variables

    public var type: String = ""
    public var logId: Int = 0
    public var levels: HATFitbitSleepLevelsObject = HATFitbitSleepLevelsObject()
    public var endTime: String = ""
    public var duration: Int = 0
    public var infoCode: Int = 0
    public var startTime: String = ""
    public var timeInBed: Int = 0
    public var efficiency: Int = 0
    public var dateOfSleep: String = ""
    public var minutesAwake: Int = 0
    public var minutesAsleep: Int = 0
    public var minutesAfterWakeup: Int = 0
    public var minutesToFallAsleep: Int = 0
}
