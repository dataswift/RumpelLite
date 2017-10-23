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

public struct HATFitbitProfileObject: HATObject {
    
    // MARK: - Variables

    public var age: Int = 0
    public var avatar: String = ""
    public var gender: String = ""
    public var height: Int = 0
    public var locale: String = ""
    public var weight: Float = 0
    public var features: HATFitbitProfileFeaturesObject = HATFitbitProfileFeaturesObject()
    public var fullName: String = ""
    public var lastName: String = ""
    public var swimUnit: String = ""
    public var timezone: String = ""
    public var avatar150: String = ""
    public var avatar640: String = ""
    public var corporate: Bool = false
    public var encodedId: String = ""
    public var firstName: String = ""
    public var dateCreated: String?
    public var topBadges: [HATFitbitProfileTopBadgesObject] = []
    public var ambassador: Bool = false
    public var heightUnit: String = ""
    public var mfaEnabled: Bool = false
    public var weightUnit: String = ""
    public var dateOfBirth: String = ""
    public var displayName: String = ""
    public var glucoseUnit: String = ""
    public var memberSince: String = ""
    public var distanceUnit: String = ""
    public var corporateAdmin: Bool = false
    public var startDayOfWeek: String = ""
    public var averageDailySteps: Int = 0
    public var displayNameSetting: String = ""
    public var offsetFromUTCMillis: Int = 0
    public var strideLengthRunning: Int = 0
    public var strideLengthWalking: Float = 0
    public var clockTimeDisplayFormat: String = ""
    public var strideLengthRunningType: String = ""
    public var strideLengthWalkingType: String = ""
}
