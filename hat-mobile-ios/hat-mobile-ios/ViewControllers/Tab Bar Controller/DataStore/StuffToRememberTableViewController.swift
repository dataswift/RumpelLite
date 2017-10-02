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

internal class StuffToRememberTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    private var stuffToRemember: [StuffToRememberObject] = []
    
    private var bodyCellSize: CGFloat = 43
    
    private let headers: [String] = ["Body"]
    
    // MARK: - IBActions
    
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.updateModelFromUI()
        
        StuffToRememberCachingWrapper.postStuffToRememberObject(
            stuffToRememberObject: self.stuffToRemember[0],
            userToken: userToken,
            userDomain: userDomain,
            successCallback: {
                
                self.navigationController?.popViewController(animated: true)
            },
            errorCallback: failedRequest)
    }
    
    // MARK: - Auto Generated methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTableViewCellHeight(notif:)), name: NSNotification.Name(rawValue: "updateTableViewRow"), object: nil)
    }
    
    @objc
    func updateTableViewCellHeight(notif: Notification) {
        
        if let tempSize = notif.object as? String {
            
            let array = tempSize.split(separator: " ", maxSplits: 2, omittingEmptySubsequences: true)
            if !array.isEmpty {
                
                guard let cellIndex = Int(array[0]), let cellHeight = Double(array[1]) else {
                    
                    return
                }
                
                if cellIndex == 0 {
                    
                    self.bodyCellSize = CGFloat(cellHeight) + 15
                }
            }
            
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.stuffToRemember = [StuffToRememberObject()]
        
        StuffToRememberCachingWrapper.getStuffToRememberObject(
            userToken: self.userToken,
            userDomain: self.userDomain,
            cacheTypeID: "stuffToRememberObject",
            successRespond: self.gotStuffToRemember,
            failRespond: self.failedRequest)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
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
                cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.stuffToRemember, for: indexPath) as? PhataTableViewCell
                cell = self.setUpCell(cell: cell!, indexPath: indexPath) as? PhataTableViewCell
            }
            
            // body
            if index == 0 {
                
                self.stuffToRemember[0].body = cell!.getTextFromTextField()
            }
        }
    }
    
    // MARK: - Failed request
    
    private func failedRequest(error: HATTableError) {
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    // MARK: - Got Stuff to Remember
    
    private func gotStuffToRemember(receivedStuffToRemember: [StuffToRememberObject], newToken: String?) {
        
        if !receivedStuffToRemember.isEmpty {
            
            self.stuffToRemember = [receivedStuffToRemember.last!]
        }
        
        self.tableView.reloadData()
        KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: newToken)
    }
    
    // MARK: - Table view methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.headers[section]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.stuffToRemember, for: indexPath) as? PhataTableViewCell {
            
            return setUpCell(cell: cell, indexPath: indexPath)
        }
        
        return tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.stuffToRemember, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.bodyCellSize
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     
     - returns: The set up cell
     */
    private func setUpCell(cell: PhataTableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.accessoryType = .none
        
        if indexPath.section == 0 && !self.stuffToRemember.isEmpty {
            
            cell.setTextToTextField(text: self.stuffToRemember[0].body)
        }
        
        return cell
    }

}
