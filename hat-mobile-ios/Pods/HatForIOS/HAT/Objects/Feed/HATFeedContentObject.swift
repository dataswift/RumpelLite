//
//  HATFeedContentObject.swift
//  HAT
//
//  Created by Marios-Andreas Tsekis on 30/10/17.
//  Copyright © 2017 HATDeX. All rights reserved.
//

public struct HATFeedContentObject: Codable {

    public var text: String?
    public var media: [HATFeedContentMediaObject]?
}
