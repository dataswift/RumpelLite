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

/// A class representing the outer data plug JSON format
public struct HATDataPlugObject: Decodable {

    // MARK: - Variables

    /// The unique id of the data plug
    public var plug: HATDataPlugPlugObject = HATDataPlugPlugObject()
    /// The name of the data plug
    public var provider: HATDataPlugProviderObject = HATDataPlugProviderObject()
}
