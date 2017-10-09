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

import UIKit

public struct HATDataPlugPlugObject: Decodable {

    public var uuid: String = ""
    public var providerId: String = ""
    public var created: Int = 0
    public var name: String = ""
    public var description: String = ""
    public var url: String = ""
    public var illustrationUrl: String = ""
    public var passwordHash: String = ""
    public var approved: Bool = false
    
    public var showCheckMark: Bool? = false
}
