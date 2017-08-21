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

/// A class responsible for the profile relationship and household, in dataStore ViewController
internal class DataStoreRelationshipAndHouseholdTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables

    /// The sections of the table view
    private let sections: [[String]] = [["Relationship Status"], ["Type of Accomodation"], ["Living Situation"], ["How many usually live in your household?"], ["How many children do you have?"], ["Do you have any additional dependents?"]]
    /// The headers of the table view
    private let headers: [String] = ["Relationship Status", "Type of Accomodation", "Living Situation", "How many usually live in your household?", "How many children do you have?", "Do you have any additional dependents?"]
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The relationship and household object used to save all the values downloaded from the server and also used to produce the JSON to update to the server
    private var livingInfo: HATLivingInfoObject = HATLivingInfoObject()
    
    // MARK: - IBAction
    
    /**
     Saves the nationality to hat
     
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
        
        func success(json: JSON, newToken: String?) {
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        func failed(error: HATTableError) {
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }

        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.LivingInfo.source,
            dataPath: Constants.HATTableName.LivingInfo.name,
            parameters: self.livingInfo.toJSON(),
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
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreRelationshipCell, for: indexPath) as? PhataTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath, livingInfo: self.livingInfo) as? PhataTableViewCell
            }
            
            if index == 0 {
                
                self.livingInfo.relationshipStatus = cell!.getTextFromTextField()
            } else if index == 1 {
                
                self.livingInfo.typeOfAccomodation = cell!.getTextFromTextField()
            } else if index == 2 {
                
                self.livingInfo.livingSituation = cell!.getTextFromTextField()
            } else if index == 3 {
                
                self.livingInfo.numberOfPeopleInHousehold = cell!.getTextFromTextField()
            } else if index == 4 {
                
                self.livingInfo.numberOfChildren = cell!.getTextFromTextField()
            } else if index == 5 {
                
                self.livingInfo.numberOfDecendants = cell!.getTextFromTextField()
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
    
    // MARK: - View Controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        self.getLivingInfo()
    }
    
    // MARK: - Get Living Info
    
    private func getLivingInfo () {
        
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.LivingInfo.source,
            scope: Constants.HATTableName.LivingInfo.name,
            parameters: ["take": "1", "orderBy": "unixTimeStamp", "ordering": "descending"],
            successCallback: updateTableWithValuesFrom,
            errorCallback: errorFetching)
    }
    // MARK: - Completion handlers
    
    /**
     Updates the table with the new value returned from HAT
     
     - parameter nationalityObject: The nationality object returned from HAT
     */
    func updateTableWithValuesFrom(array: [JSON], newToken: String?) {
        
        if !array.isEmpty {
            
            self.livingInfo = HATLivingInfoObject(from: array[0])
            self.tableView.reloadData()
        }
    }
    
    /**
     Logs the error if it's not noValuesFund
     
     - parameter error: The error returned from HAT
     */
    func errorFetching(error: HATTableError) {
        
        switch error {
        case .noValuesFound:
            
            self.livingInfo = HATLivingInfoObject()
        default:
            
            _ = CrashLoggerHelper.hatTableErrorLog(error: error)
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreRelationshipCell, for: indexPath) as? PhataTableViewCell {
            
            return setUpCell(cell: cell, indexPath: indexPath, livingInfo: self.livingInfo)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreRelationshipCell, for: indexPath)
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
     - parameter nationality: The nationality object used to set up the cell
     
     - returns: The set up cell
     */
    func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath, livingInfo: HATLivingInfoObject) -> UITableViewCell {
        
        cell.accessoryType = .none
        
        if indexPath.section == 0 {
            
            cell.setTextToTextField(text: livingInfo.relationshipStatus)
            cell.setTagInTextField(tag: 15)
            cell.dataSourceForPickerView = ["Married", "Engaged", "Living together", "Single", "Divorced", "Widowed", "Do not want to say"]
            cell.setKeyboardType(.default)
        } else if indexPath.section == 1 {
            
            cell.setTextToTextField(text: livingInfo.typeOfAccomodation)
            cell.setTagInTextField(tag: 15)
            cell.dataSourceForPickerView = ["Detached House", "Flat", "Semi-detached", "Terraced", "End Terrace", "Cottage", "Bungalow", "Do not want to say"]
            cell.setKeyboardType(.default)
        } else if indexPath.section == 2 {
            
            cell.setTextToTextField(text: livingInfo.livingSituation)
            cell.setTagInTextField(tag: 15)
            cell.dataSourceForPickerView = ["own a home", "renting", "living with parents", "homeless", "Do not want to say"]
            cell.setKeyboardType(.default)
        } else if indexPath.section == 3 {
            
            cell.setTextToTextField(text: livingInfo.numberOfPeopleInHousehold)
            cell.setTagInTextField(tag: 15)
            cell.dataSourceForPickerView = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "Do not want to say"]
            cell.setKeyboardType(.default)
        } else if indexPath.section == 4 {
            
            cell.setTextToTextField(text: String(describing: livingInfo.numberOfChildren))
            cell.setTagInTextField(tag: 15)
            cell.dataSourceForPickerView = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "Do not want to say"]
            cell.setKeyboardType(.default)
        } else if indexPath.section == 5 {
            
            cell.setTextToTextField(text: livingInfo.numberOfDecendants)
            cell.setTagInTextField(tag: 15)
            cell.dataSourceForPickerView = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "Do not want to say"]
            cell.setKeyboardType(.default)
        }
        
        return cell
    }

}
