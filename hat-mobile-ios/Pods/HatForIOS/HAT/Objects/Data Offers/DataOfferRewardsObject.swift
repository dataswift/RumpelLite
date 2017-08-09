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

public struct DataOfferRewardsObject {
    
    // MARK: - JSON Fields
    
    public struct Fields {
        
        static let rewardType: String = "rewardType"
        static let rewardVendor: String = "vendor"
        static let vendorURL: String = "vendorUrl"
        static let rewardValue: String = "value"
        static let currency: String = "currency"
        static let codesReuseable: String = "codesReuseable"
        static let codes: String = "codes"
        static let cashValue: String = "cashValue"
    }
    
    // MARK: - Variables
    
    public var rewardType: String = ""
    public var vendor: String = ""
    public var vendorURL: String = ""
    public var value: String = ""
    public var valueInt: Int?
    public var areCodesReusable: Bool?
    public var codes: [String]?
    public var cashValue: DataOfferRewardsCashValueObject?
    public var currency: String?
    
    // MARK: - Initialiser
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        rewardType = ""
        vendor = ""
        vendorURL = ""
        value = ""
        valueInt = nil
        areCodesReusable = nil
        codes = nil
        cashValue = nil
        currency = nil
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(dictionary: Dictionary<String, JSON>) {
        
        if let tempRewardType = dictionary[DataOfferRewardsObject.Fields.rewardType]?.string {
            
            rewardType = tempRewardType
        }
        
        if let tempVendor = dictionary[DataOfferRewardsObject.Fields.rewardVendor]?.string {
            
            vendor = tempVendor
        }
        
        if let tempVendorUrl = dictionary[DataOfferRewardsObject.Fields.vendorURL]?.string {
            
            vendorURL = tempVendorUrl
        }
        
        if let tempValue = dictionary[DataOfferRewardsObject.Fields.rewardValue]?.string {
            
            value = tempValue
        }
        
        if let tempCurrency = dictionary[DataOfferRewardsObject.Fields.currency]?.string {
            
            currency = tempCurrency
        }
        
        if let tempIntValue = dictionary[DataOfferRewardsObject.Fields.rewardValue]?.int {
            
            valueInt = tempIntValue
        }
        
        if let tempCodeReusable = dictionary[DataOfferRewardsObject.Fields.codesReuseable]?.bool {
            
            areCodesReusable = tempCodeReusable
        }
        
        if let tempCodesArray = dictionary[DataOfferRewardsObject.Fields.codes]?.array {
            
            codes = []
            for code in tempCodesArray {
                
                if let unwrappedCode = code.string {
                    
                    codes?.append(unwrappedCode)
                }
            }
        }
        
        if let tempCashValue = dictionary[DataOfferRewardsObject.Fields.cashValue]?.dictionary {
            
            cashValue = DataOfferRewardsCashValueObject(dictionary: tempCashValue)
        }
    }
}
