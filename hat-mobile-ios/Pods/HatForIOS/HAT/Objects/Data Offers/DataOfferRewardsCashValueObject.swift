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

public struct DataOfferRewardsCashValueObject {

    // MARK: - JSON Fields
    
    public struct Fields {
        
        static let rewardType: String = "rewardType"
        static let currency: String = "currency"
        static let value: String = "value"
    }
    
    // MARK: - Variables
    
    public var rewardType: String = ""
    public var value: Int = 0
    public var currency: String = ""
    
    // MARK: - Initialiser
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        rewardType = ""
        value = 0
        currency = ""
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dictionary: Dictionary<String, JSON>) {
        
        if let tempRewardType = dictionary[DataOfferRewardsCashValueObject.Fields.rewardType]?.string {
            
            rewardType = tempRewardType
        }
        
        if let tempValue = dictionary[DataOfferRewardsCashValueObject.Fields.value]?.int {
            
            value = tempValue
        }
        
        if let tempCurrency = dictionary[DataOfferRewardsCashValueObject.Fields.currency]?.string {
            
            currency = tempCurrency
        }
    }
}
