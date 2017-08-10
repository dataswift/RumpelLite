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

// MARK: Struct

internal struct GoDeepObject {

    // MARK: - Variables
    
    /// The image for the app
    var appImage: UIImage = UIImage()
    
    /// The service name of the app
    var appName: String = ""
    /// The url of the app
    var appURL: String = ""
    /// The description of the app
    var appDescription: String = ""
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        appName = ""
        appURL = ""
        appDescription = ""
        appImage = UIImage()
    }
    
    /**
     It initialises everything from the passed values
     */
    init(name: String, url: String, description: String, image: UIImage) {
        
        self.init()
        
        appName = name
        appURL = url
        appDescription = description
        appImage = image
    }
    
    // MARK: - Return the 4 tiles we need for the home screen
    
    /**
     Returns the 4 tiles we need for the Home Screen
     
     - returns: An array of 4 HomeScreenObject for display in home screen
     */
    static func setUpTilesForApps() -> [GoDeepObject] {
        
        let shape = GoDeepObject(
            name: "Shape/Influence",
            url: "https://www.shapeinfluence.com",
            description: "See offers that might be interesting to your influencers",
            image: UIImage(named: Constants.ImageNames.shapeInfluence)!)
        let podSense = GoDeepObject(
            name: "Podsense",
            url: "https://www.nogginasia.com/podsense/",
            description: "The app that pays you for sharing your data",
            image: UIImage(named: Constants.ImageNames.podsense)!)
        let savy = GoDeepObject(
            name: "Savy",
            url: "https://www.savy.io",
            description: "Your personal data account",
            image: UIImage(named: Constants.ImageNames.savy)!)
        let hospify = GoDeepObject(
            name: "Hospify",
            url: "https://www.hospify.com",
            description: "Mobile messaging app compliant for health use across UK & EU",
            image: UIImage(named: Constants.ImageNames.hospify)!)
        
        return [shape, podSense, savy, hospify]
    }
}
