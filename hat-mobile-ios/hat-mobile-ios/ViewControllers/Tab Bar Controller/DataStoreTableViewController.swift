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

// MARK: Class

/// A class responsible for the data store, profile, view controller
internal class DataStoreTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables

    /// The sections of the table view
    private let sections: [[String]] = [["Name", "Contact Info"], ["UK Specific"], ["For Data Offers"]]
    /// The headers of the table view
    private let headers: [String] = ["My Profile"]
    
    /// The profile, used in PHATA table
    private var profile: HATProfileObject?
    
    var prefferedTitle: String = "Data Store"
    var prefferedInfoMessage: String = "Your personal data store for all numbers and important things to remember"

    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var infoPopUpButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func infoPopUp(_ sender: Any) {
        
        self.showInfoViewController(text: prefferedInfoMessage)
        self.infoPopUpButton.isUserInteractionEnabled = false
    }
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = self.prefferedTitle
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        HATPhataService.getProfileFromHAT(
            userDomain: userDomain,
            userToken: userToken,
            successCallback: getProfile,
            failCallback: logError)
    }
    
    /**
     If the profile table has been created get the profile values from HAT
     
     - parameter dictionary: The dictionary returned from hat
     - parameter renewedToken: The new token returned from hat
     */
    func tableCreated(dictionary: Dictionary<String, Any>, renewedToken: String?) {
        
        HATPhataService.getProfileFromHAT(
            userDomain: userDomain,
            userToken: userToken,
            successCallback: getProfile,
            failCallback: logError)
    }
    
    /**
     Gets profile from hat and saves it to a local variable
     
     - parameter receivedProfile: The received HATProfileObject from HAT
     */
    private func getProfile(receivedProfile: HATProfileObject) {
        
        self.profile = receivedProfile
    }
    
    /**
     Logs the error occured
     
     - parameter error: The HATTableError occured
     */
    private func logError(error: HATTableError) {
        
        self.profile = HATProfileObject()
        
        switch error {
        case .tableDoesNotExist:
            
            let tableJSON = HATJSONHelper.createProfileTableJSON()
            HATAccountService.createHatTable(
                userDomain: userDomain,
                token: userToken,
                notablesTableStructure: tableJSON,
                failed: {(error) in
                
                    CrashLoggerHelper.hatTableErrorLog(error: error)
                }
            )(
                
                HATAccountService.checkHatTableExistsForUploading(
                    userDomain: userDomain,
                    tableName: Constants.HATTableName.Profile.name,
                    sourceName: Constants.HATTableName.Profile.source,
                    authToken: userToken,
                    successCallback: tableCreated,
                    errorCallback: logError)
            )
        default:
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreCell, for: indexPath)
        
        return setUpCell(cell: cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToName, sender: self)
            } else if indexPath.row == 1 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToContactInfoSegue, sender: self)
            }
        } else if indexPath.section == 1 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToUKSpecificSegue, sender: self)
            }
        } else if indexPath.section == 2 {
            
            if indexPath.row == 0 {
                
                self.performSegue(withIdentifier: Constants.Segue.dataStoreToForDataOffersInfoSegue, sender: self)
            }
        }
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     
     - returns: The set up cell
     */
    func setUpCell(cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.textLabel?.text = self.sections[indexPath.section][indexPath.row]
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    // MARK: - Remove pop up
    
    /**
     Hides pop up presented currently
     */
    @objc
    private func hidePopUp() {
        
        self.darkView?.removeFromSuperview()
        self.infoPopUpButton.isUserInteractionEnabled = true
    }
    
    // MARK: - Add blur View
    
    /**
     Adds blur to the view before presenting the pop up
     */
    private func addBlurToView() {
        
        self.darkView = AnimationHelper.addBlurToView(self.view)
    }
    
    /**
     Shows the pop up view controller with the info passed on
     
     - parameter text: A String to show in the view controller
     */
    private func showInfoViewController(text: String) {
        
        // set up page controller
        let textPopUpViewController = TextPopUpViewController.customInit(
            stringToShow: text,
            isButtonHidden: true,
            from: self.storyboard!)
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(
            frame: CGRect(
                x: self.view.frame.origin.x + 15,
                y: self.tableView.frame.maxY,
                width: self.view.frame.width - 30,
                height: self.view.frame.height),
            color: .teal,
            cornerRadius: 15)
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                // add the page view controller to self
                weakSelf.addBlurToView()
                weakSelf.addViewController(textPopUpViewController!)
                AnimationHelper.animateView(
                    textPopUpViewController?.view,
                    duration: 0.2,
                    animations: {() -> Void in
                        
                        textPopUpViewController?.view.frame = CGRect(
                            x: weakSelf.view.frame.origin.x + 15,
                            y: weakSelf.tableView.frame.maxY - 250,
                            width: weakSelf.view.frame.width - 30,
                            height: 300)
                },
                    completion: { _ in return }
                )
            }
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if self.profile != nil {
            
            if segue.destination is DataSourceNameTableViewController {
                
                weak var destinationVC = segue.destination as? DataSourceNameTableViewController
                
                if segue.identifier == Constants.Segue.dataStoreToName {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is DataStoreContactInfoTableViewController {
                
                weak var destinationVC = segue.destination as? DataStoreContactInfoTableViewController
                
                if segue.identifier == Constants.Segue.dataStoreToContactInfoSegue {
                    
                    destinationVC?.profile = self.profile
                }
            }
        }
    }

}
