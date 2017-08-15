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

internal struct HomeScreenSegueObject {
    
    // MARK: - Variables
    
    var titleToPassOnToTheNextView: String = ""
    var infoPopUpToPassOnToTheNextView: String = ""
    var specificMerchantForOffers: String = ""
    var segueName: String = ""
    var showAlert: Bool = false
    
    // MARK: - Set up passing value

    static func setUpPassingSegueValuesBy(name: String, viewController: HomeViewController) -> HomeScreenSegueObject {
        
        var object = HomeScreenSegueObject()
        
        if name == "Top Secret Logs" {
            
            object.titleToPassOnToTheNextView = "Top Secret Logs"
            object.infoPopUpToPassOnToTheNextView = "Daily log, diary and innermost thoughts can all go in here!"
            object.segueName = Constants.Segue.notesSegue
        } else if name == "GEOME" {
            
            object.titleToPassOnToTheNextView = "GEOME"
            object.infoPopUpToPassOnToTheNextView = "Check back where you were by using the date picker!"
            object.segueName = Constants.Segue.locationsSegue
        } else if name == "My Story" {
            
            object.titleToPassOnToTheNextView = "My Story"
            object.infoPopUpToPassOnToTheNextView = "Still work-in-progress, this is where you can see your social feed and notes."
            object.segueName = Constants.Segue.socialDataSegue
        } else if name == "Photo Viewer" {
            
            object.segueName = Constants.Segue.photoViewerSegue
        } else if name == "Social Media Control" {
            
            object.infoPopUpToPassOnToTheNextView = "Post something on social media (FB or Twitter) or on HATTERS bulletin board. Share for 1/7/14/30 days and it would be deleted when the note expires! Or delete it instantly at the shared location by moving the note to private. Add your location or a photo!"
            object.titleToPassOnToTheNextView = "Social Media Control"
            object.segueName = Constants.Segue.homeToEditNoteSegue
        } else if name == "The calling card" {
            
            object.infoPopUpToPassOnToTheNextView = "Your PHATA is your public profile. Enable it to use it as a calling card!"
            object.titleToPassOnToTheNextView = "The calling card"
            object.segueName = Constants.Segue.phataSegue
        } else if name == "Total Recall" {
            
            object.infoPopUpToPassOnToTheNextView = "Your personal data store for all numbers and important things to remember"
            object.titleToPassOnToTheNextView = "Total Recall"
            object.segueName = Constants.Segue.homeToDataStore
        } else if name == "Gimme" {
            
            object.infoPopUpToPassOnToTheNextView = "Pull in your data with the HAT data Plugs"
            object.titleToPassOnToTheNextView = "Gimme"
            object.segueName = Constants.Segue.homeToDataPlugs
        } else if name == "Watch-eet" {
            
            object.infoPopUpToPassOnToTheNextView = "Accept an offer to curate personalised entertainment (videos, movies) for your data. Pick the curator who might have the best algorithms to entertain you. Keep your list to watch later! Watch-eet is currently work-in-progress. During this time, HAT owners will see all recommendations, without any matching of data in your HAT."
            object.titleToPassOnToTheNextView = "Watch-eet"
            object.specificMerchantForOffers = "rumpelwatch"
            object.segueName = Constants.Segue.homeToDataOffers
        } else if name == "Read-eet" {
            
            object.infoPopUpToPassOnToTheNextView = "Accept an offer to curate personalised news, books and other reading materials, matched with your personal data. Keep your list to read later. Read-eet is currently work-in-progress. During this time, HAT owners see all recommendations, without any matching of data in your HAT."
            object.titleToPassOnToTheNextView = "Read-eet"
            object.specificMerchantForOffers = "rumpelread"
            object.segueName = Constants.Segue.homeToDataOffers
        } else if name == "Do-eet" {
            
            object.infoPopUpToPassOnToTheNextView = "Accept an offer to do a digital action, whether it’s to tweet something (fulfilled by your Twitter data), be somewhere (fulfilled by your location data) or run (fulfilled by Fitbit data). Get rewarded for your digital actions!"
            object.titleToPassOnToTheNextView = "Do-eet"
            object.specificMerchantForOffers = "rumpeldo"
            object.segueName = Constants.Segue.homeToDataOffers
        } else if name == "Match Me" {
            
            object.titleToPassOnToTheNextView = "Match Me"
            object.infoPopUpToPassOnToTheNextView = "Fill up your preference profile so that it can be matched with products and services out there"
            object.segueName = Constants.Segue.homeToForDataOffersSettingsSegue
        } else if name == "Find your Form" {
            
            object.titleToPassOnToTheNextView = "Find your Form"
            object.specificMerchantForOffers = "rumpelforms"
            object.segueName = Constants.Segue.homeToDataOffers
        } else if name == "Go deep" {
            
            object.titleToPassOnToTheNextView = "Go deep"
            object.segueName = Constants.Segue.homeToGoDeepSegue
        } else if name == "MadHATTERs" {
            
            UIApplication.shared.openURL(URL(string: "http://us12.campaign-archive2.com/home/?u=bf49285ca77275f68a5263b83&id=3ca9558266")!)
        } else if name == "HAT" {
            
            UIApplication.shared.openURL(URL(string: "http://mailchi.mp/hatdex/hat-news-pieces-of-art-earning-from-your-attention-and-reading-your-name-1017509")!)
        } else if name == "HATTERs" {
            
            UIApplication.shared.openURL(URL(string: "https://hatters.hubofallthings.com/community")!)
        } else if name == "Ideas" {
            
            UIApplication.shared.openURL(URL(string: "https://marketsquare.hubofallthings.com/ideas")!)
        } else if name == "BeMoji" {
            
            object.infoPopUpToPassOnToTheNextView = "Broadcast your mood. Pick an emoji and broadcast it!"
            object.titleToPassOnToTheNextView = "BeMoji"
            object.segueName = Constants.Segue.homeToEditNoteSegue
        } else if name == "Featured Offers" {
            
            object.showAlert = true
        }
        
        return object
    }
}
