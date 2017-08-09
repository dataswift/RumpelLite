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
import SafariServices
import SwiftyJSON

internal class DetailsDataPlugViewController: UIViewController, UserCredentialsProtocol {

    var plug: String = ""
    var plugURL: String = ""
    
    var safariVC: SFSafariViewController?
    
    @IBAction func connectPlug(_ sender: Any) {
        
        self.safariVC = SFSafariViewController.openInSafari(url: plugURL, on: self, animated: true, completion: nil)
    }
    
    @IBAction func viewDataPlugData(_ sender: Any) {
        
        self.performSegue(withIdentifier: "detailsToSocialFeed", sender: self)
    }
    
    // MARK: - Notification observer method
    
    /**
     Hides safari view controller
     
     - parameter notif: The notification object sent
     */
    @objc
    private func showAlertForDataPlug(notif: Notification) {
        
        // check that safari is not nil, if it's not hide it
        self.safariVC?.dismissSafari(animated: true, completion: nil)
        //self.checkFacebookPlugIfExpired()
    }
    
    @IBOutlet private weak var textView: UITextView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(showAlertForDataPlug),
            name: Notification.Name(Constants.NotificationNames.dataPlug),
            object: nil)
        
        if plug == "facebook" {
            
            self.loadFacebookInfo()
        } else {
            
            self.loadTwitterInfo()
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func loadFacebookInfo() {
        
        func tableFound(tableID: NSNumber, newToken: String?) {
            
            func gotProfile(profile: [JSON], renewedToken: String?) {
                
                let profile = profile[0].dictionaryValue["data"]?["profile"]
                let stringToShow: NSMutableAttributedString = NSMutableAttributedString(string: "")
                for (key, value) in (profile?.dictionaryValue)! {
                    
                    stringToShow.append(NSMutableAttributedString(string: "\(key): \(value)"))
                    stringToShow.append(NSAttributedString(string:"\n"))
                }
                
                self.textView.attributedText = stringToShow
            }
            
            HATAccountService.getHatTableValues(
                token: userToken,
                userDomain: userDomain,
                tableID: tableID,
                parameters: [:],
                successCallback: gotProfile,
                errorCallback: tableNotFound)
        }
        
        HATAccountService.checkHatTableExists(
            userDomain: userDomain,
            tableName: "profile",
            sourceName: "facebook",
            authToken: userToken,
            successCallback: tableFound,
            errorCallback: tableNotFound)
    }
    
    func loadTwitterInfo() {
        
        func gotTweets(tweets: [JSON], newToken: String?) {
            
            let user = tweets[0].dictionaryValue["data"]?["tweets"]["user"]
            let stringToShow: NSMutableAttributedString = NSMutableAttributedString(string: "")
            for (key, value) in (user?.dictionaryValue)! {
                
                stringToShow.append(NSMutableAttributedString(string: "\(key): \(value)"))
                stringToShow.append(NSAttributedString(string:"\n"))
            }
            
            self.textView.attributedText = stringToShow
        }
        
        HATTwitterService.checkTwitterDataPlugTable(
            authToken: userToken,
            userDomain: userDomain,
            parameters: ["limit": "1"],
            success: gotTweets)
    }
    
    func tableNotFound(error: HATTableError) {
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "detailsToSocialFeed" {
            
            if let vc = segue.destination as? SocialFeedViewController {
                
                if plug == "facebook" {
                    
                    vc.filterBy = "Facebook"
                } else {
                    
                    vc.filterBy = "Twitter"
                }
            }
        }
    }

}
