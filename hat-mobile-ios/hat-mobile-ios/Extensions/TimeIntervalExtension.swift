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

import Foundation

// MARK: Extension

extension TimeInterval {
    
    // MARK: - Variables
    
    var milliseconds: Int {
        
        return Int((self.truncatingRemainder(dividingBy: 1)) * 1000)
    }
    
    var seconds: Int {
        
        return Int(self.remainder(dividingBy: 60))
    }
    
    var minutes: Int {
        
        return Int((self / 60).remainder(dividingBy: 60))
    }
    
    var hours: Int {
        
        return Int(self / (60 * 60))
    }
    
    var stringTime: String {
        
        if self.hours != 0 {
            
            return "\(self.hours)h \(self.minutes)m"// \(self.seconds)s"
        } else if self.minutes != 0 {
            
            return "\(self.minutes)m \(self.seconds)s"
        } else if self.milliseconds != 0 {
            
            return "\(self.seconds)s \(self.milliseconds)ms"
        } else {
            
            return "\(self.seconds)s"
        }
    }
}
