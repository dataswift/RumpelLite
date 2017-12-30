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
    
    /// A string representing the title of the pushed view controller
    var titleToPassOnToTheNextView: String = ""
    /// A string message to show in the info pop up in the pushed view controller
    var infoPopUpToPassOnToTheNextView: String = ""
    /// A string representing the specific merchant for data offers
    var specificMerchantForOffers: String = ""
    /// A string representing the name of the segue to execute
    var segueName: String = ""
    
    /// A bool flag to indicate the need to show an alert
    var showAlert: Bool = false
    
    // MARK: - Set up passing value

    /**
     Sets up the data needed for passing into the next ViewController
     
     - parameter name: The service name, tile name
     - parameter viewController: The view controller that calls this method

     - returns: An HomeScreenSegueObject object holding all the info to pass during the segue into the next ViewController
     */
    static func setUpPassingSegueValuesBy(name: String, viewController: HomeViewController) -> HomeScreenSegueObject {
        
        var object = HomeScreenSegueObject()
        
        if name == "Notables" {
            
            object.titleToPassOnToTheNextView = "Notables"
            object.infoPopUpToPassOnToTheNextView = "Daily log, diary and innermost thoughts can all go in here!"
            object.segueName = Constants.Segue.notesSegue
        } else if name == "Locations" {
            
            object.titleToPassOnToTheNextView = "GEOME"
            object.infoPopUpToPassOnToTheNextView = "Check back where you were by using the date picker!"
            object.segueName = Constants.Segue.locationsSegue
        } else if name == "My Story" {
            
            object.titleToPassOnToTheNextView = "My Story"
            object.infoPopUpToPassOnToTheNextView = "Still work-in-progress, this is where you can see your social feed and notes."
            object.segueName = Constants.Segue.socialDataSegue
        } else if name == "Photo Viewer" {
            
            object.segueName = Constants.Segue.photoViewerSegue
        }  else if name == "PHATA Profile" {
            
            object.infoPopUpToPassOnToTheNextView = "Your PHATA is your public profile. Enable it to use it as a calling card!"
            object.titleToPassOnToTheNextView = "PHATA Profile"
            object.segueName = Constants.Segue.phataSegue
        } else if name == "Data Store" {
            
            object.infoPopUpToPassOnToTheNextView = "Your personal data store for all numbers and important things to remember"
            object.titleToPassOnToTheNextView = "Data Store"
            object.segueName = Constants.Segue.homeToDataStore
        } else if name == "Gimme" {
            
            object.infoPopUpToPassOnToTheNextView = "Pull in your data with the HAT data Plugs"
            object.segueName = Constants.Segue.homeToDataPlugs
        } else if name == "My Preferences" {
            
            object.titleToPassOnToTheNextView = "My Preferences"
            object.infoPopUpToPassOnToTheNextView = "Fill up your preference profile so that it can be matched with products and services out there. No personal identity information is shared"
            object.segueName = Constants.Segue.homeToForDataOffersSettingsSegue
        } else if name == "Find your Form" {
            
            object.titleToPassOnToTheNextView = "Find your Form"
            object.specificMerchantForOffers = "rumpelforms"
            object.segueName = Constants.Segue.homeToDataOffers
        } else if name == "Go deep" {
            
            object.titleToPassOnToTheNextView = "Go deep"
            object.segueName = Constants.Segue.homeToGoDeepSegue
        } else if name == "MadHATTERs" {
            
            UIApplication.shared.openURL(URL(string: "https://hatters.hubofallthings.com/madhatters")!)
        } else if name == "HAT" {
            
            UIApplication.shared.openURL(URL(string: "http://www.hatdex.org/whats-new-hat/")!)
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
