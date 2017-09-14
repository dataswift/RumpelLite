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

import SafariServices
import XCTest

internal class FastlaneScreenshots: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        KeychainHelper.clearKeychainKey(key: Constants.Keychain.logedIn)
        KeychainHelper.clearKeychainKey(key: Constants.Keychain.userToken)
        KeychainHelper.clearKeychainKey(key: Constants.Keychain.hatDomainKey)
        KeychainHelper.clearKeychainKey(key: Constants.Keychain.trackDeviceKey)
        KeychainHelper.clearKeychainKey(key: Constants.Keychain.newUser)
        
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testTakeScreeshots() {
        
        let app = XCUIApplication()
        XCUIDevice.shared().orientation = .portrait
        
        if app.textFields["HAT address"].exists {
            
            app.textFields["HAT address"].tap()
            app.textFields["HAT address"].typeText("appletest")
            app.buttons["Login"].tap()
            
            sleep(5)
            
            let passwordSecureTextField = app.webViews.secureTextFields["Password"]
            passwordSecureTextField.tap()
            passwordSecureTextField.typeText("gate7Apple!")
            app.webViews.buttons["Login"].tap()
            
            sleep(5)
        }
        
        snapshot("01HomeScreen")
        
        let collectionViewsQuery = app.collectionViews
        collectionViewsQuery.staticTexts["Top Secret Logs"].tap()
        sleep(1)
        snapshot("02TopSecretLogs")
        app.navigationBars["Top Secret Logs"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
        
        collectionViewsQuery.staticTexts["My locations in time"].tap()
        sleep(1)
        snapshot("04Locations")
        app.navigationBars["GEOME"].children(matching: .button).matching(identifier: "Back").element(boundBy: 0).tap()
        
        let tabBarsQuery = app.tabBars
        
        tabBarsQuery.buttons["Data Plugs"].tap()
        sleep(1)
        snapshot("05Plugs")
        
        tabBarsQuery.buttons["Data Offers"].tap()
        app.alerts["Heads up!"].buttons["OK"].tap()
        sleep(1)
        snapshot("06Offers")
    }
    
}
