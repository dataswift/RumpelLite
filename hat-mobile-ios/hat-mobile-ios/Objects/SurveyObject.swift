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

import HatForIOS
import SwiftyJSON

// MARK: Struct

internal struct SurveyObject {
    
    // MARK: - Fields
    
    private struct Fields {
        
        static let question: String = "question"
        static let answer: String = "answer"
        static let recordID: String = "recordID"
        static let unixTimeStamp: String = "unixTimeStamp"
    }

    // MARK: - Variables
    
    var question: String = ""
    var answer: Int = 0
    var recordID: String = ""
    var date: Date = Date()
    
    // MARK: - Initialisers
    
    init() {
        
        question = ""
        answer = 0
        recordID = ""
        date = Date()
    }
    
    init(from dict: JSON) {
        
        if let data = (dict["data"].dictionary) {
            
            if let tempQuestion = (data[Fields.question]?.stringValue) {
                
                question = tempQuestion
            }
            
            if let tempAnswer = (data[Fields.answer]?.intValue) {
                
                answer = tempAnswer
            }
            
            if let tempDate = (data[Fields.unixTimeStamp]?.intValue) {
                
                date = HATFormatterHelper.formatStringToDate(string: String(describing: tempDate))!
            }
        }
        
        recordID = (dict[Fields.recordID].stringValue)
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            Fields.question: self.question,
            Fields.answer: self.answer,
            Fields.unixTimeStamp: Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!
        ]
        
    }
}
