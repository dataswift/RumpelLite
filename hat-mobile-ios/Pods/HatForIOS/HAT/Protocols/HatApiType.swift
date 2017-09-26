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

// MARK: Protocol

public protocol HatApiType {
    
    func toJSON() -> Dictionary<String, Any>
    
    mutating func initialize(fromCache: Dictionary<String, Any>)
    
    init()
}

// MARK: - Extension
//swiftlint:disable extension_access_modifier
extension HatApiType {
    
    public init(fromCache: Dictionary<String, Any>) {
        
        self.init()
        
        self.initialize(fromCache: fromCache)
    }
}
//swiftlint:enable extension_access_modifier
