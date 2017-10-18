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

public struct HATFitbitWeightObject: HATObject {
    
    // MARK: - Variables

    public var bmi: Float = 0
    public var fat: Float = 0
    public var date: String = ""
    public var time: String = ""
    public var logId: Int = 0
    public var source: String = ""
    public var weight: Float = 0
}
