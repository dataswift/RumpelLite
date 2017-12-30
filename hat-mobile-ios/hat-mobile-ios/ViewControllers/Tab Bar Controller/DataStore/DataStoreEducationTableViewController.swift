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

/// A class responsible for the profile education, in dataStore ViewController
internal class DataStoreEducationTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables

    /// The sections of the table view
    private let sections: [[String]] = [["What is the highest academic qualification?"]]
    /// The headers of the table view
    private let headers: [String] = ["What is the highest academic qualification?"]
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The nationality object used to save all the values downloaded from the server and also used to produce the JSON to update to the server
    private var education: HATProfileEducationObject = HATProfileEducationObject()
    
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
        
        EducationCachingWrapperHelper.postEducation(
            education: self.education,
            userToken: userToken,
            userDomain: userDomain,
            successCallback: {
                
                DispatchQueue.main.async { [weak self] in
                    
                    self?.loadingView.removeFromSuperview()
                    self?.darkView.removeFromSuperview()
                    
                    _ = self?.navigationController?.popViewController(animated: true)
                }
            },
            errorCallback: { error in
                
                DispatchQueue.main.async { [weak self] in
                    
                    self?.loadingView.removeFromSuperview()
                    self?.darkView.removeFromSuperview()
                    
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
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreEducationCell, for: indexPath) as? PhataTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath, education: self.education) as? PhataTableViewCell
            }
            
            if index == 0 {
                
                self.education.highestAcademicQualification = cell!.getTextFromTextField()
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
    
    // MARK: - View Controller Function
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.allowsSelection = false
        
        DispatchQueue.main.async { [weak self] in
            
            self?.tableView.isUserInteractionEnabled = false
            guard let midX = self?.tableView?.frame.midX,
                let midY = self?.tableView?.frame.midY,
                let font = UIFont(name: Constants.FontNames.openSans, size: 12),
                let weakSelf = self else {
                    
                    return
            }
            
            weakSelf.loadingView.removeFromSuperview()
            weakSelf.loadingView = UIView.createLoadingView(
                with: CGRect(x: midX - 70, y: midY - 15, width: 160, height: 30),
                color: .teal,
                cornerRadius: 15,
                in: weakSelf.view,
                with: "Getting profile...",
                textColor: .white,
                font: font)
            
            EducationCachingWrapperHelper.getEducation(
                userToken: weakSelf.userToken,
                userDomain: weakSelf.userDomain,
                cacheTypeID: "education",
                successRespond: weakSelf.updateTableWithValuesFrom,
                failRespond: weakSelf.errorFetching)
        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Completion handlers
    
    /**
     Updates the table with the new value returned from HAT
     
     - parameter nationalityObject: The nationality object returned from HAT
     */
    func updateTableWithValuesFrom(education: [HATProfileEducationObject], newString: String?) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.tableView.isUserInteractionEnabled = true
            self?.loadingView.removeFromSuperview()
            self?.education = education[0]
            self?.tableView.reloadData()
        }
    }
    
    /**
     Logs the error if it's not noValuesFund
     
     - parameter error: The error returned from HAT
     */
    func errorFetching(error: HATTableError) {
        
        DispatchQueue.main.async { [weak self] in
            
            guard let weakSelf = self else {
                
                return
            }
            
            weakSelf.tableView.isUserInteractionEnabled = true
            weakSelf.loadingView.removeFromSuperview()
            
            switch error {
            case .noValuesFound:
                
                weakSelf.education = HATProfileEducationObject()
            default:
                
                _ = CrashLoggerHelper.hatTableErrorLog(error: error)
            }
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreEducationCell, for: indexPath) as? PhataTableViewCell {
            
            return setUpCell(cell: cell, indexPath: indexPath, education: self.education)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dataStoreEducationCell, for: indexPath)
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
    func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath, education: HATProfileEducationObject) -> UITableViewCell {
        
        cell.accessoryType = .none

        if indexPath.section == 0 {
            
            cell.dataSourceForPickerView = ["GCSE/O levels", "High School/A levels", "Bachelors degree", "Masters degree", "Doctorate", "Do not want to say"]
            cell.setTextToTextField(text: education.highestAcademicQualification)
            cell.setTagInTextField(tag: 11)
            cell.setKeyboardType(.default)
        }
        
        return cell
    }

}
