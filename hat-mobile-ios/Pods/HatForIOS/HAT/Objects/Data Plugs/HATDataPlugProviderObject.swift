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

public struct HATDataPlugProviderObject: Decodable {

    public var id: String = ""
    public var email: String = ""
    public var emailConfirmed: Bool = false
    public var password: String = ""
    public var name: String = ""
    public var dateCreated: Int = 0
}
