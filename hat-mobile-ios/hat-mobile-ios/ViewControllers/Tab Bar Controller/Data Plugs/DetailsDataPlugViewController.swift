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

// MARK: Class

internal class DetailsDataPlugViewController: UIViewController, UserCredentialsProtocol, UITableViewDataSource {
    
    // MARK: - Model
    
    /// A struct to hold the name and the value of the plug
    private struct PlugDetails {
        
        var name: String = ""
        var value: String = ""
    }
    
    // MARK: - Variables

    /// The plug name, passed on from previous view controller
    var plug: String = ""
    /// The plug url, passed on from previous view controller
    var plugURL: String = ""
    
    /// The safari view controller reference
    private var safariVC: SFSafariViewController?
    
    /// The plug details
    private var plugDetailsArray: [PlugDetails] = []
    
    // MARK: - IBOutlets
    
    /// An IBOutlet fon handling the tableView UITableView
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - IBActions
    
    /**
     Connects the plug
     
     - parameter sender: The object that calls this method
     */
    @IBAction func connectPlug(_ sender: Any) {
        
        self.safariVC = SFSafariViewController.openInSafari(url: plugURL, on: self, animated: true, completion: nil)
    }
    
    /**
     View data plug details
     
     - parameter sender: The object that calls this method
     */
    @IBAction func viewDataPlugData(_ sender: Any) {
        
        self.performSegue(withIdentifier: Constants.Segue.detailsToSocialFeed, sender: self)
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
    }
    
    // MARK: - Auto-generated methods
    
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
    
    // MARK: - Table View methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return plugDetailsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.plugDetailsCell, for: indexPath) as? DataPlugDetailsTableViewCell
        
        if indexPath.row % 2 == 0 {
            
            cell?.backgroundColor = .gray
        } else {
            
            cell?.backgroundColor = .white
        }
        cell?.setTitleToLabel(title: self.plugDetailsArray[indexPath.row].name)
        cell?.setDetailsToLabel(details: self.plugDetailsArray[indexPath.row].value)
        
        return cell!
    }
    
    // MARK: - Facebook Info
    
    /**
     Get facebook info
     */
    func loadFacebookInfo() {
        
        func tableFound(tableID: NSNumber, newToken: String?) {
            
            func gotProfile(profile: [JSON], renewedToken: String?) {
                
                if !profile.isEmpty {
                    
                    if let profile = profile[0].dictionaryValue["data"]?["profile"].dictionaryValue {
                        
                        for (key, value) in profile {
                            
                            var object = PlugDetails()
                            object.name = key
                            object.value = value.stringValue
                            
                            self.plugDetailsArray.append(object)
                        }
                        
                        self.tableView.reloadData()
                    }
                }
            }
            
            HATAccountService.getHatTableValues(
                token: userToken,
                userDomain: userDomain,
                tableID: tableID,
                parameters: ["starttime": "0"],
                successCallback: gotProfile,
                errorCallback: tableNotFound)
        }
        
        HATAccountService.checkHatTableExists(
            userDomain: userDomain,
            tableName: Constants.HATTableName.FacebookProfile.name,
            sourceName: Constants.HATTableName.FacebookProfile.source,
            authToken: userToken,
            successCallback: tableFound,
            errorCallback: tableNotFound)
    }
    
    // MARK: - Twitter Info
    
    /**
     Get twitter info
     */
    func loadTwitterInfo() {
        
        func gotTweets(tweets: [JSON], newToken: String?) {
            
            let user = tweets[0].dictionaryValue["data"]?["tweets"]["user"]
            for (key, value) in (user?.dictionaryValue)! {
                
                var object = PlugDetails()
                object.name = key
                object.value = value.stringValue
                
                self.plugDetailsArray.append(object)
            }
            
            self.tableView.reloadData()
        }
        
        HATTwitterService.checkTwitterDataPlugTable(
            authToken: userToken,
            userDomain: userDomain,
            parameters: ["limit": "1"],
            success: gotTweets)
    }
    
    /**
     HAT returned an error while trying to retrieve the data
     
     - parameter error: The HATTableError returned from the HAT
     */
    func tableNotFound(error: HATTableError) {
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.detailsToSocialFeed {
        
            if let vc = segue.destination as? SocialFeedViewController {
                
                if plug == "facebook" {
                    
                    vc.filterBy = "Facebook"
                    vc.prefferedTitle = "Facebook Plug"
                } else {
                    
                    vc.filterBy = "Twitter"
                    vc.prefferedTitle = "Twitter Plug"
                }
            }
        }
    }

}
