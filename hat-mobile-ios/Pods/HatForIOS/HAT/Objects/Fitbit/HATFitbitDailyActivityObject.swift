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

public struct HATFitbitDailyActivityObject: HATObject {
    
    // MARK: - Variables

    public var steps: Int = 0
    public var floors: Int = 0
    public var distances: [HATFitbitDailyActivityDistanceObject] = []
    public var elevation: Int = 0
    public var activeScore: Int = 0
    public var caloriesBMR: Int = 0
    public var caloriesOut: Int = 0
    public var activityCalories: Int = 0
    public var marginalCalories: Int = 0
    public var sedentaryMinutes: Int = 0
    public var veryActiveMinutes: Int = 0
    public var fairlyActiveMinutes: Int = 0
    public var lightlyActiveMinutes: Int = 0
}
