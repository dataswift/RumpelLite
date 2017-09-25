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

/// A class responsible for the profile nationality, in dataStore ViewController
internal class DataStoreEmploymentStatusTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables

    /// The sections of the table view
    private let sections: [[String]] = [["Employment Status"]]
    /// The headers of the table view
    private let headers: [String] = ["Employment Status"]
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The nationality object used to save all the values downloaded from the server and also used to produce the JSON to update to the server
    private var employmentStatus: HATEmployementStatusObject = HATEmployementStatusObject()
    
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
    
    // MARK: - Upload info
    
    /**
     Uploads the model to hat
     */
    private func uploadInfoToHat() {
        
        func success() {
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        func error(error: HATTableError) {
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
        
        EmploymentCachingWrapperHelper.postEmployment(
            employmentStatus: self.employmentStatus,
            userToken: userToken,
            userDomain: userDomain,
            successCallback: success,
            errorCallback: error)
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
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreEmploymentCell, for: indexPath) as? PhataTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath, employmentStatus: self.employmentStatus) as? PhataTableViewCell
            }
            
            if index == 0 {
                
                self.employmentStatus.status = cell!.getTextFromTextField()
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
        
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Updating profile...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
    }
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false

        self.getEmploymentStatus()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Get Employment Status
    
    private func getEmploymentStatus() {
        
        self.tableView.isUserInteractionEnabled = false
        
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Getting profile...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        
        EmploymentCachingWrapperHelper.getEmployment(
            userToken: userToken,
            userDomain: userDomain,
            cacheTypeID: "employment",
            successRespond: updateTableWithValuesFrom,
            failRespond: errorFetching)
    }
    // MARK: - Completion handlers
    
    /**
     Updates the table with the new value returned from HAT
     
     - parameter nationalityObject: The nationality object returned from HAT
     */
    func updateTableWithValuesFrom(array: [HATEmployementStatusObject], newToken: String?) {
        
        self.tableView.isUserInteractionEnabled = true
        self.loadingView.removeFromSuperview()
        
        if !array.isEmpty {
            
            self.employmentStatus = array[0]
            self.tableView.reloadData()
        }
    }
    
    /**
     Logs the error if it's not noValuesFund
     
     - parameter error: The error returned from HAT
     */
    func errorFetching(error: HATTableError) {
        
        self.tableView.isUserInteractionEnabled = true
        self.loadingView.removeFromSuperview()
        
        switch error {
        case .noValuesFound:
            
            self.employmentStatus = HATEmployementStatusObject()
        default:
            
            _ = CrashLoggerHelper.hatTableErrorLog(error: error)
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreEmploymentCell, for: indexPath) as? PhataTableViewCell {
            
            return setUpCell(cell: cell, indexPath: indexPath, employmentStatus: self.employmentStatus)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreEmploymentCell, for: indexPath)
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
    func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath, employmentStatus: HATEmployementStatusObject) -> UITableViewCell {
        
        cell.accessoryType = .none
        
        if indexPath.section == 0 {
            
            cell.setTextToTextField(text: employmentStatus.status)
            cell.setTagInTextField(tag: 15)
            cell.dataSourceForPickerView = ["Employed", "Self Employed", "Unemployed", "Student", "Do not wish to say"]
            cell.setKeyboardType(.default)
        }

        return cell
    }

}
