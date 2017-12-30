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

extension Date {

    func getTimeOfDay() -> String {
        
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: self)
        let minutes = calendar.component(.minute, from: self)
        return "\(hour):\(minutes)"
    }
    
    // MARK: - Time ago
    
    /**
     Returns a string of time ago
     
     - returns: a formatted string of time-ago
     */
    public func timeAgoSinceDate() -> String {
        
        // get calendar and now date
        let calendar = Calendar.current
        let dateNow = self
        
        // calculate the earliest
        let earliestDate = (dateNow as NSDate).earlierDate(self)
        // calculate the latest
        let latestDate = (earliestDate == dateNow) ? self : dateNow
        
        // set up the componenets
        let components: DateComponents = (calendar as NSCalendar).components(
            [NSCalendar.Unit.minute, NSCalendar.Unit.hour, NSCalendar.Unit.day, NSCalendar.Unit.weekOfYear, NSCalendar.Unit.month, NSCalendar.Unit.year, NSCalendar.Unit.second],
            from: earliestDate,
            to: latestDate,
            options: NSCalendar.Options())
        
        // check the components and return the correct string
        if components.year! >= 2 {
            
            return NSLocalizedString("Last year", comment: "")
        } else if components.month! >= 2 {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d months ago", comment: ""), components.month!)
        } else if components.weekOfYear! >= 1 {
            
            return NSLocalizedString("A week ago", comment: "")
        } else if components.day! >= 2 {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d days ago", comment: ""), components.day!)
        } else if components.day! >= 1 {
            
            return NSLocalizedString("A day ago", comment: "")
        } else if components.hour! >= 2 {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d hours ago", comment: ""), components.hour!)
        } else if components.hour! >= 1 {
            
            return NSLocalizedString("An hour ago", comment: "")
        } else if components.minute! >= 2 {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d minutes ago", comment: ""), components.minute!)
        } else if components.minute! >= 1 {
            
            return NSLocalizedString("A minute ago", comment: "")
        } else if components.second! >= 3 {
            
            return String.localizedStringWithFormat(NSLocalizedString("%d seconds ago", comment: ""), components.second!)
        } else {
            
            return NSLocalizedString("Just now", comment: "")
        }
    }
    
    // MARK: - Get start of the day
    
    /**
     Returns the start of the date
     
     - returns: The date called the method but with time 00:00:00
     */
    func startOfDate(date: Date = Date()) -> Date {
        
        return Calendar.current.startOfDay(for: date)
    }
    
    func endOfDate(date: Date = Date()) -> Date? {
        
        var components = DateComponents()
        components.day = 1
        components.second = -1
        let startOfDay = Date().startOfDate(date: date)
        return Calendar.current.date(byAdding: components, to: startOfDay)
    }
    
    static func startOfDateInUnixTimeStape(date: Date = Date()) -> Int {
        
        let date: Date = Date().startOfDate(date: date)
        return Int(date.timeIntervalSince1970)
    }
    
    static func endOfDateInUnixTimeStape(date: Date = Date()) -> Int? {
        
        //For End Date
        if let endOfDate = Date().endOfDate(date: date) {
            
            return Int(endOfDate.timeIntervalSince1970)
        }
        
        return nil
    }
}
