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

// MARK: Class

/// A class representing the tiles in the home screen
internal class HomeScreenObject: NSObject {
    
    // MARK: - Variables

    /// The image for the tile
    var serviceImage: UIImage = UIImage()
    
    /// The service name of the tile
    var serviceName: String = ""
    /// The description of the tile
    var serviceDescription: String = ""
    
    // MARK: - Initialisers
    
    /**
     The default initialiser. Initialises everything to default values.
     */
    override init() {
        
        serviceName = ""
        serviceDescription = ""
        serviceImage = UIImage()
    }
    
    /**
     It initialises everything from the passed values
     */
    convenience init(name: String, description: String, image: UIImage) {
        
        self.init()
        
        serviceName = name
        serviceDescription = description
        serviceImage = image
    }
    
    // MARK: - Return the 4 tiles we need for the home screen
    
    /**
     Returns the 4 tiles we need for the Home Screen
     
     - returns: An array of 4 HomeScreenObject for display in home screen
     */
    class func setUpTilesForHomeScreen() -> [HomeScreenObject] {
        
        let topSecret = HomeScreenObject(
            name: "Top Secret Logs",
            description: "Notes to self",
            image: UIImage(named: Constants.ImageNames.notesImage)!)
        let geoMe = HomeScreenObject(
            name: "GEOME",
            description: "My locations in time",
            image: UIImage(named: Constants.ImageNames.gpsOutlinedImage)!)
        let myStory = HomeScreenObject(
            name: "My Story",
            description: "My digital life",
            image: UIImage(named: Constants.ImageNames.socialFeedImage)!)
        let photoView = HomeScreenObject(
            name: "Photo Viewer",
            description: "Show the images you have uploaded in your HAT",
            image: UIImage(named: Constants.ImageNames.photoViewerImage)!)
        let socialMediaControl = HomeScreenObject(
            name: "Social Media Control",
            description: "Share only what I want, for as long as I want",
            image: UIImage(named: Constants.ImageNames.socialMediaControl)!)
        let meDigital = HomeScreenObject(
            name: "The calling card",
            description: "My PHATA public profile",
            image: UIImage(named: Constants.ImageNames.callingCard)!)
        let allThatIsMine = HomeScreenObject(
            name: "Total Recall",
            description: "Information I always need in my data store",
            image: UIImage(named: Constants.ImageNames.recall)!)
        _ = HomeScreenObject(
            name: "BeMoji",
            description: "Broadcast my mood",
            image: UIImage(named: Constants.ImageNames.bemoji)!)
        let sso = HomeScreenObject(
            name: "Match Me",
            description: "My preferences",
            image: UIImage(named: Constants.ImageNames.profileOutline)!)
        _ = HomeScreenObject(
            name: "Find your Form",
            description: "No more form filling. Check-in to Hotels, Spas, places",
            image: UIImage(named: Constants.ImageNames.news)!)
        let madhatters = HomeScreenObject(
            name: "MadHATTERs",
            description: "Tech news with a HAT perspective",
            image: UIImage(named: Constants.ImageNames.community)!)
        let hatCommunity = HomeScreenObject(
            name: "HAT",
            description: "What's new",
            image: UIImage(named: Constants.ImageNames.hatLogo)!)
        let ideas = HomeScreenObject(
            name: "Ideas",
            description: "Contribute ideas that will make HAT better",
            image: UIImage(named: Constants.ImageNames.ideas)!)
        let hatters = HomeScreenObject(
            name: "HATTERs",
            description: "Community Space",
            image: UIImage(named: Constants.ImageNames.hattersOutline)!)
        
        return [topSecret, geoMe, myStory, socialMediaControl, meDigital, allThatIsMine, sso, photoView, hatCommunity, madhatters, ideas, hatters]
    }
}
