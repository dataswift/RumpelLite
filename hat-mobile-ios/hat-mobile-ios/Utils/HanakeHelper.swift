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

import Haneke

internal struct HanakeHelper {

    static func getCacheSize(completion: @escaping (Float) -> Void) {
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        let cache = imageView.hnk_cacheFormat
        
        HNKCache.shared().getSizeOfCache(cache, completion: {size in

            completion(size)
        })
    }
    
    static func clearCache() {
        
        HNKCache.shared().removeAllImages()
    }
}
