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

public struct PurchaseObject: HATObject {
    
    // MARK: - Variables

    public var firstName: String = ""
    public var termsAgreed: Bool = false
    public var lastName: String = ""
    public var email: String = ""
    public var hatName: String = ""
    public var password: String = ""
    public var hatCluster: String = ""
    public var hatCountry: String = ""
    public var membership: PurchaseMembershipObject = PurchaseMembershipObject()
    
    // MARK: - Initialisers
    
    public init() {
        
    }
}
