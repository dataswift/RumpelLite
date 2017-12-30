//
//  HATFeedObject.swift
//  HAT
//
//  Created by Marios-Andreas Tsekis on 30/10/17.
//  Copyright © 2017 HATDeX. All rights reserved.
//

// MARK: Struct

public struct HATFeedObject: HATObject {

    public var date: HATFeedDateObject = HATFeedDateObject()
    public var source: String = ""
    public var content: HATFeedContentObject?
    public var title: HATFeedTitleObject = HATFeedTitleObject()
    // public var location: String = ""
}
