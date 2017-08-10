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
    
    struct PlugDetails {
        
        var name: String = ""
        var value: String = ""
    }
    
    // MARK: - Variables

    var plug: String = ""
    var plugURL: String = ""
    
    var safariVC: SFSafariViewController?
    
    private var plugDetailsArray: [PlugDetails] = []
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - IBActions
    
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "PlugDetailsCell", for: indexPath) as? DataPlugDetailsTableViewCell
        
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
            tableName: "profile",
            sourceName: "facebook",
            authToken: userToken,
            successCallback: tableFound,
            errorCallback: tableNotFound)
    }
    
    // MARK: - Twitter Info
    
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
    
    func tableNotFound(error: HATTableError) {
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    // MARK: - Navigation
    
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
