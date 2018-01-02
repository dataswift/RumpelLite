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

/// A class responsible for the profile contact info, in dataStore ViewController
internal class DataStoreContactInfoTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Email"], ["Mobile Number"], ["Home Address"], ["House/Flat Number"], ["Post Code"]]
    /// The headers of the table view
    private let headers: [String] = ["Email", "Mobile Number", "Home Address", "House/Flat Number", "Post Code"]
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The profile, used in PHATA table
    var profile: ProfileObject?
    private var profileAddress: HATProfileAddress = HATProfileAddress()
    
    // MARK: - IBAction

    /**
     Saves the profile to hat
     
     - parameter sender: The object that called this function
     */
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.createPopUp()
        self.updateModelFromUI()
        self.uploadInfoToHat()
    }
    
    // MARK: - Create error Alert
    
    /**
     Creates an error alert based on when the error occured
     
     - parameter title: The title of the alert
     - parameter message: The message of the alert
     - parameter error: The error to log on crashlytics
     */
    private func createErrorAlertWith(title: String, message: String, error: HATTableError) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.loadingView.removeFromSuperview()
            self?.darkView.removeFromSuperview()
            
            self?.createClassicOKAlertWith(
                alertMessage: message,
                alertTitle: title,
                okTitle: "OK",
                proceedCompletion: {})
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
    }
    
    // MARK: - Upload info
    
    /**
     Uploads the model to hat
     */
    private func uploadInfoToHat() {
        
        ProfileCachingHelper.postProfile(
            profile: self.profile!,
            userToken: userToken,
            userDomain: userDomain,
            successCallback: { [weak self] in
                
                DispatchQueue.main.async {
                    
                    self?.loadingView.removeFromSuperview()
                    self?.darkView.removeFromSuperview()
                    
                    self?.navigationController?.popViewController(animated: true)
                }
            },
            errorCallback: { [weak self] error in
                
                DispatchQueue.main.async {
                    
                    self?.loadingView.removeFromSuperview()
                    self?.darkView.removeFromSuperview()
                    
                    self?.createClassicOKAlertWith(
                        alertMessage: "There was an error posting profile",
                        alertTitle: "Error",
                        okTitle: "OK",
                        proceedCompletion: {})
                    CrashLoggerHelper.hatTableErrorLog(error: error)
                }
            }
        )
        
        AddressCachingWrapperHelper.postProfileAddress(
            profileAddresses: [profileAddress],
            userToken: userToken,
            userDomain: userDomain,
            successCallback: { },
            errorCallback: { [weak self] error in
                
                DispatchQueue.main.async {
                    
                    self?.loadingView.removeFromSuperview()
                    self?.darkView.removeFromSuperview()
                    
                    self?.createClassicOKAlertWith(
                        alertMessage: "There was an error posting profile address",
                        alertTitle: "Error",
                        okTitle: "OK",
                        proceedCompletion: {})
                    CrashLoggerHelper.hatTableErrorLog(error: error)
                }
            }
        )
    }
    
    // MARK: - Update Model
    
    /**
     Maps the UI to the model in order to update the values
     */
    private func updateModelFromUI() {
        
        for index in self.headers.indices {
            
            var cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? PhataTableViewCell
            
            if cell == nil {
                
                let indexPath = IndexPath(row: 0, section: index)
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.profileInfoCell, for: indexPath) as? PhataTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath) as? PhataTableViewCell
            }
            
            // email
            if index == 0 {
                
                profile?.profile.data.contact.primaryEmail = cell!.getTextFromTextField()
                // Mobile
            } else if index == 1 {
                
                profile?.profile.data.contact.mobile = cell!.getTextFromTextField()
            // street name
            } else if index == 2 {

                profileAddress.streetAddress = cell!.getTextFromTextField()
            // street number
            } else if index == 3 {

                profileAddress.houseNumber = cell!.getTextFromTextField()
            // postcode
            } else if index == 4 {

                profileAddress.postCode = cell!.getTextFromTextField()
            }
        }
    }
    
    // MARK: - Create PopUp
    
    /**
     Creates Updating profile... pop up while the uploading is taking place
     */
    private func createPopUp() {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let weakSelf = self else {
                
                return
            }
            
            weakSelf.darkView = UIView(frame: weakSelf.view.frame)
            weakSelf.darkView.backgroundColor = .black
            weakSelf.darkView.alpha = 0.4
            
            weakSelf.view.addSubview(weakSelf.darkView)
            
            weakSelf.loadingView = UIView.createLoadingView(
                with: CGRect(x: (weakSelf.view?.frame.midX)! - 70, y: (weakSelf.view?.frame.midY)! - 15, width: 140, height: 30),
                color: .teal,
                cornerRadius: 15,
                in: weakSelf.view,
                with: "Updating profile...",
                textColor: .white,
                font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        }
    }
    
    // MARK: - View Controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        AddressCachingWrapperHelper.getProfileAddress(
            userToken: userToken,
            userDomain: userDomain,
            cacheTypeID: "profileAddress",
            successRespond: receivedProfileAddress,
            failRespond: { [weak self] error in
                
                DispatchQueue.main.async {
                    
                    self?.loadingView.removeFromSuperview()
                    self?.darkView.removeFromSuperview()
                    
                    self?.createClassicOKAlertWith(
                        alertMessage: "There was an error getting profileAddress",
                        alertTitle: "Error",
                        okTitle: "OK",
                        proceedCompletion: {})
                    CrashLoggerHelper.hatTableErrorLog(error: error)
                }
            }
        )
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Received Profile Address

    private func receivedProfileAddress(address: [HATProfileAddress], newToken: String?) {
        
        if !address.isEmpty {
            
            self.profileAddress = address[0]
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreContactInfoCell, for: indexPath) as? PhataTableViewCell {
            
            return setUpCell(cell: cell, indexPath: indexPath)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreContactInfoCell, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     
     - returns: The set up cell
     */
    func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.accessoryType = .none

        if profile != nil {
            
            // email
            if indexPath.section == 0 {
                
                cell.setTextToTextField(text: self.profile!.profile.data.contact.primaryEmail)
                cell.setKeyboardType(.emailAddress)
                // Mobile
            } else if indexPath.section == 1 {
                
                cell.setTextToTextField(text: self.profile!.profile.data.contact.mobile)
                cell.setKeyboardType(.numberPad)
            // street name
            } else if indexPath.section == 2 {
                
                cell.setTextToTextField(text: self.profileAddress.streetAddress)
                cell.setKeyboardType(.default)
            // street number
            } else if indexPath.section == 3 {
                
                cell.setTextToTextField(text: self.profileAddress.houseNumber)
                cell.setKeyboardType(.default)
            // address postcode
            } else if indexPath.section == 4 {
                
                cell.setTextToTextField(text: self.profileAddress.postCode)
                cell.setKeyboardType(.default)
            }
        }

        return cell
    }

}
