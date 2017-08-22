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
internal class DataStoreUKSpecificTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["National Insurance Number"], ["NHS Number"], ["Driving License Number"], ["Passport Number"], ["Expiry date"], ["Place of birth"], ["Second passport Number"], ["Second passport Expiry date"]]
    /// The headers of the table view
    private let headers: [String] = ["National Insurance Number", "NHS Number", "Driving License Number", "Passport Number", "Expiry date", "Place of birth", "Second passport Number", "Second passport Expiry date"]
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The profile, used in PHATA table
    private var ukSpecificInfo: UKSpecificInfo = UKSpecificInfo()
    
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
        
        self.createClassicOKAlertWith(
            alertMessage: message,
            alertTitle: title,
            okTitle: "OK",
            proceedCompletion: {})
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    // MARK: - Upload info
    
    /**
     Uploads the model to hat
     */
    private func uploadInfoToHat() {
        
        func recordCreated(json: JSON, newToken: String?) {
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        let json = self.ukSpecificInfo.toJSON()
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.UKSpecificInfo.source,
            dataPath: Constants.HATTableName.UKSpecificInfo.name,
            parameters: json,
            successCallback: recordCreated,
            errorCallback: failedGettingInfo)
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
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreUKSpecificInfoCell, for: indexPath) as? PhataTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath) as? PhataTableViewCell
            }
            
            // nationalInsuranceNumber
            if index == 0 {
                
                self.ukSpecificInfo.nationalInsuranceNumber = cell!.getTextFromTextField()
            // nhsNumber
            } else if index == 1 {
                
                self.ukSpecificInfo.nhsNumber = cell!.getTextFromTextField()
            // drivingLicenseNumber
            } else if index == 2 {
                
                self.ukSpecificInfo.drivingLicenseNumber = cell!.getTextFromTextField()
            // passportNumber
            } else if index == 3 {
                
                self.ukSpecificInfo.passportNumber = cell!.getTextFromTextField()
            // passportExpiryDate
            } else if index == 4 {
                
                if let date = HATFormatterHelper.formatStringToDate(string: cell!.getTextFromTextField()) {
                    
                    self.ukSpecificInfo.passportExpiryDate = date
                }
            // placeOfBirth
            } else if index == 5 {
                
                self.ukSpecificInfo.placeOfBirth = cell!.getTextFromTextField()
            // secondPassportNumber
            } else if index == 6 {
                
                self.ukSpecificInfo.secondPassportNumber = cell!.getTextFromTextField()
            // secondPassportExpiryDate
            } else if index == 7 {
                
                if let date = HATFormatterHelper.formatStringToDate(string: cell!.getTextFromTextField()) {
                    
                    self.ukSpecificInfo.secondPassportExpiryDate = date
                }
            }
        }
    }
    
    // MARK: - Create PopUp
    
    /**
     Creates Updating profile... pop up while the uploading is taking place
     */
    private func createPopUp() {
        
        self.darkView = UIView(frame: self.view.frame)
        self.darkView.backgroundColor = .black
        self.darkView.alpha = 0.4
        
        self.view.addSubview(self.darkView)
        
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Updating profile...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
    }
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        self.getUKInfoFromHAT()
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreUKSpecificInfoCell, for: indexPath) as? PhataTableViewCell {
            
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
        
        if indexPath.section == 0 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo.nationalInsuranceNumber)
        } else if indexPath.section == 1 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo.nhsNumber)
        } else if indexPath.section == 2 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo.drivingLicenseNumber)
        } else if indexPath.section == 3 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo.passportNumber)
        } else if indexPath.section == 4 {
            
            cell.setTextToTextField(
                text: FormatterHelper.formatDateStringToUsersDefinedDate(
                date: self.ukSpecificInfo.passportExpiryDate,
                dateStyle: .short,
                timeStyle: .none)
            )
            cell.setKeyboardType(.default)
            cell.setTagInTextField(tag: 12)
        } else if indexPath.section == 5 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo.placeOfBirth)
            cell.setTagInTextField(tag: 5)
        } else if indexPath.section == 6 {
            
            cell.setTextToTextField(text: self.ukSpecificInfo.secondPassportNumber)
        } else if indexPath.section == 7 {
            
            cell.setTextToTextField(
                text: FormatterHelper.formatDateStringToUsersDefinedDate(
                    date: self.ukSpecificInfo.secondPassportExpiryDate,
                    dateStyle: .short,
                    timeStyle: .none)
            )
            cell.setKeyboardType(.default)
            cell.setTagInTextField(tag: 12)
        }
        
        return cell
    }
    
    func failedGettingInfo(error: HATTableError) {
        
        self.tableView.isUserInteractionEnabled = true
        self.loadingView.removeFromSuperview()
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    func getUKInfoFromHAT() {
        
        func gotInfo(array: [JSON], newToken: String?) {
            
            self.tableView.isUserInteractionEnabled = true
            self.loadingView.removeFromSuperview()
            
            if !array.isEmpty {
                
                self.ukSpecificInfo = UKSpecificInfo(from: array[0])
                self.tableView.reloadData()
            }
        }
        
        self.tableView.isUserInteractionEnabled = false
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.tableView?.frame.midX)! - 70, y: (self.tableView?.frame.midY)! - 15, width: 160, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Loading HAT data...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)

        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.UKSpecificInfo.source,
            scope: Constants.HATTableName.UKSpecificInfo.name,
            parameters: ["take": "1", "orderBy": "unixTimeStamp", "ordering": "descending"],
            successCallback: gotInfo,
            errorCallback: failedGettingInfo)
    }
    
}
