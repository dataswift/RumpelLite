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
import SwiftyJSON

// MARK: Class

/// A class responsible for the profile name, in dataStore ViewController
internal class DataSourceNameTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["First Name"], ["Middle Name"], ["Last Name"], ["Preffered Name"], ["Title"]]
    /// The headers of the table view
    private let headers: [String] = ["First Name", "Middle Name", "Last Name", "Preffered Name", "Title"]
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The profile, used in PHATA table
    var profile: ProfileObject?
    
    // MARK: - IBAction
    
    /**
     Saves the profile to hat
     
     - parameter sender: The object that called this function
     */
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.createPopUp(message: "Updating profile...")
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
                if let tempCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreNameCell, for: indexPath) as? PhataTableViewCell {
                    
                    cell = self.setUpCell(cell: tempCell, indexPath: indexPath) as? PhataTableViewCell
                }
            }
            if cell != nil {
                
                // first name
                if index == 0 {
                    
                    profile?.profile.data.personal.firstName = cell!.getTextFromTextField()
                    // Middle name
                } else if index == 1 {
                    
                    profile?.profile.data.personal.middleName = cell!.getTextFromTextField()
                    // Last name
                } else if index == 2 {
                    
                    profile?.profile.data.personal.lastName = cell!.getTextFromTextField()
                    // Preffered name
                } else if index == 3 {
                    
                    profile?.profile.data.personal.preferredName = cell!.getTextFromTextField()
                    // Title
                } else if index == 4 {
                    
                    profile?.profile.data.personal.title = cell!.getTextFromTextField()
                }
            }
        }
    }
    
    // MARK: - Create PopUp
    
    /**
     Creates Updating profile... pop up while the uploading is taking place
     */
    private func createPopUp(message: String) {
        
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
                with: message,
                textColor: .white,
                font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        }
    }
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        self.tableView.allowsSelection = false
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreNameCell, for: indexPath) as? PhataTableViewCell {
            
            return setUpCell(cell: cell, indexPath: indexPath)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreNameCell, for: indexPath)
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
        
        if indexPath.section == 0 && self.profile != nil {
            
            cell.setTextToTextField(text: self.profile!.profile.data.personal.firstName)
        } else if indexPath.section == 1 && self.profile != nil {
            
            cell.setTextToTextField(text: self.profile!.profile.data.personal.middleName)
        } else if indexPath.section == 2 && self.profile != nil {
            
            cell.setTextToTextField(text: self.profile!.profile.data.personal.lastName)
        } else if indexPath.section == 3 && self.profile != nil {
            
            cell.setTextToTextField(text: self.profile!.profile.data.personal.preferredName)
        } else if indexPath.section == 4 && self.profile != nil {
            
            cell.setTagInTextField(tag: 15)
            cell.dataSourceForPickerView = ["", "Mr.", "Mrs.", "Miss", "Dr."]
            cell.setTextToTextField(text: self.profile!.profile.data.personal.title)
        }
        
        return cell
    }

}
