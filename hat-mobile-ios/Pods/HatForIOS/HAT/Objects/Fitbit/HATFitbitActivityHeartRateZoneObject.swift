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

import SwiftyJSON

// MARK: Struct

public struct HATFitbitActivityHeartRateZoneObject: HATObject {
    
    // MARK: - Variables

    public var max: Int = 0
    public var min: Int = 0
    public var name: String = ""
    public var minutes: Int = 0
    
    init(from: JSON) {
        
        let dictionary = self.extractContent(from: from)
        guard let test: HATFitbitActivityHeartRateZoneObject = HATFitbitActivityHeartRateZoneObject.decode(from: dictionary) else {
            
            return
        }
        
        self = test
    }
    
    public func extractContent(from: JSON) -> Dictionary<String, JSON> {
        
        return [:]
    }
}
