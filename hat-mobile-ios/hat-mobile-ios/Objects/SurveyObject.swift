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
        static let interest: String = "interest"
        static let recordID: String = "recordID"
        static let array: String = "array"
        static let unixTimeStamp: String = "unixTimeStamp"
    }

    // MARK: - Variables
    
    /// The answer in the question
    var answer: Int = 0

    /// The question
    var question: String = ""
    /// The record ID in the hat
    var recordID: String = ""
    
    /// The date that this was answered
    var date: Date = Date()
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        question = ""
        answer = 0
        recordID = ""
        date = Date()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(from dict: JSON) {
        
        if let dictionary = dict.dictionary {
            
            if let tempQuestion = dictionary[Fields.question]?.stringValue {
                
                question = tempQuestion
            }
            
            if let tempAnswer = dictionary[Fields.interest]?.intValue {
                
                answer = tempAnswer
            }
        }
        
        date = HATFormatterHelper.formatStringToDate(string: String(describing: dict[Fields.unixTimeStamp].intValue))!
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
            Fields.interest: self.answer
        ]
    }
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public static func createUnixTimeStamp() -> Int {
        
        return Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!
    }
}
