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

public struct DataDebitBundleObject: HATObject {

    // MARK: - Variables
    
    public var dateCreated: String = ""
    public var startDate: String = ""
    public var endDate: String = ""
    public var rolling: Bool = false
    public var enabled: Bool = false
    public var bundle: DataOfferRequiredDataDefinitionObjectV2 = DataOfferRequiredDataDefinitionObjectV2()
}
