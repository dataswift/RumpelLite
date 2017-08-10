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

/// A class responsible for the profile info, in dataStore ViewController
internal class DataStoreInfoTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Date of Birth"], ["I identify my gender as"], ["Income group"]]
    /// The headers of the table view
    private let headers: [String] = ["Date of Birth", "I identify my gender as", "Income group"]
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The profile, used in PHATA table
    var profile: HATProfileInfo = HATProfileInfo()
    
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
        
        self.loadingView.removeFromSuperview()
        self.darkView.removeFromSuperview()
        
        self.createClassicOKAlertWith(alertMessage: message, alertTitle: title, okTitle: "OK", proceedCompletion: {})
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    // MARK: - Upload info
    
    /**
     Uploads the model to hat
     */
    private func uploadInfoToHat() {
        
        func success(json: JSON, newToken: String?) {
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        func failed(error: HATTableError) {
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.ProfileInfo.source,
            dataPath: Constants.HATTableName.ProfileInfo.name,
            parameters: self.profile.toJSON(),
            successCallback: success,
            errorCallback: failed)
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
            
            // birth
            if index == 0 {
                
                if let date = HATFormatterHelper.formatStringToDate(string: cell!.getTextFromTextField()) {
                    
                    profile.dateOfBirth = date
                }
            // gender
            } else if index == 1 {
                
                profile.gender = cell!.getTextFromTextField()
            // income group
            } else if index == 2 {
                
                profile.incomeGroup = cell!.getTextFromTextField()
            }
        }
    }
    
    // MARK: - Create PopUp
    
    /**
     Creates Updating profile... pop up while the uploading is taking place
     */
    private func createPopUp() {
        
        self.darkView = UIView(frame: self.tableView.frame)
        self.darkView.backgroundColor = .black
        self.darkView.alpha = 0.4
        
        self.view.addSubview(self.darkView)
        
        self.loadingView = UIView.createLoadingView(with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30), color: .teal, cornerRadius: 15, in: self.view, with: "Updating profile...", textColor: .white, font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
    }
    
    // MARK: - View Controller funtions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        self.getProfileInfo()
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreInfoCell, for: indexPath) as? PhataTableViewCell {
            
            return setUpCell(cell: cell, indexPath: indexPath)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreInfoCell, for: indexPath)
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
        
        if indexPath.section == 0 {
            
            cell.setTagInTextField(tag: 12)
            cell.setTextToTextField(
                text: FormatterHelper.formatDateStringToUsersDefinedDate(
                    date: self.profile.dateOfBirth,
                    dateStyle: .short,
                    timeStyle: .none)
            )
            cell.setKeyboardType(.default)
        } else if indexPath.section == 1 {
            
            cell.setTagInTextField(tag: 15)
            cell.dataSourceForPickerView = ["Do not want to say", "Male", "Female", "Trans"]
            cell.setTextToTextField(text: self.profile.gender)
            cell.setKeyboardType(.default)
        } else if indexPath.section == 2 {
            
            cell.setTextToTextField(text: self.profile.incomeGroup)
            cell.setKeyboardType(.numberPad)
        }
        
        return cell
    }
    
    func failedGettingInfo(error: HATTableError) {
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    func getProfileInfo() {
        
        func gotInfo(array: [JSON], newToken: String?) {
            
            if !array.isEmpty {
                
                self.profile = HATProfileInfo(from: array[0])
                self.tableView.reloadData()
            }
        }
        
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.ProfileInfo.source,
            scope: Constants.HATTableName.ProfileInfo.name,
            parameters: ["take": "1", "orderBy": "unixTimeStamp", "ordering": "descending"],
            successCallback: gotInfo,
            errorCallback: failedGettingInfo)
    }

}
