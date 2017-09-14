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

// MARK: Class

public protocol HatApiType {
    
    func toJSON() -> Dictionary<String, Any>
    
    mutating func initialize(fromCache: Dictionary<String, Any>)
    
    init()
}

extension HatApiType {
    
    public init(fromCache: Dictionary<String, Any>) {
        
        self.init()
        
        self.initialize(fromCache: fromCache)
    }
}

/// A class representing the system status object
public struct HATSystemStatusObject: HatApiType {
    
    // MARK: - Comparable protocol
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func == (lhs: HATSystemStatusObject, rhs: HATSystemStatusObject) -> Bool {
        
        return (lhs.title == rhs.title && lhs.kind == rhs.kind)
    }
    
    /// Returns a Boolean value indicating whether the value of the first
    /// argument is less than that of the second argument.
    ///
    /// This function is the only requirement of the `Comparable` protocol. The
    /// remainder of the relational operator functions are implemented by the
    /// standard library for any type that conforms to `Comparable`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func < (lhs: HATSystemStatusObject, rhs: HATSystemStatusObject) -> Bool {
        
        return lhs.kind < rhs.kind
    }
    
    // MARK: - Variables
    
    /// The title of the object
    public var title: String = ""
    /// The kind object holding the values
    public var kind: HATSystemStatusKindObject = HATSystemStatusKindObject()
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    public init() {
        
        title = ""
        kind = HATSystemStatusKindObject()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    public init(from dictionary: Dictionary<String, JSON>) {
        
        self.init()
        
        initialize(from: dictionary)
    }
    
    public mutating func initialize(fromCache: Dictionary<String, Any>) {
        
        let dictionary = JSON(fromCache)
        self.initialize(from: dictionary.dictionaryValue)
    }
    
    public mutating func initialize(from dictionary: Dictionary<String, JSON>) {
        
        if let tempTitle = dictionary["title"]?.stringValue {
            
            title = tempTitle
        }
        if let tempKind = dictionary["kind"]?.dictionaryValue {
            
            kind = HATSystemStatusKindObject(from: tempKind)
        }
    }
    
    // MARK: - JSON Mapper
    
    /**
     Returns the object as Dictionary, JSON
     
     - returns: Dictionary<String, String>
     */
    public func toJSON() -> Dictionary<String, Any> {
        
        return [
            
            "title": self.title,
            "kind": self.kind.toJSON()
        ]
    }
}
