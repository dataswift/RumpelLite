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

import UIKit

// MARK: Class

/// A class responsible for the profile name, in dataStore ViewController
internal class DataStoreForDataOffersTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Education"], ["Info"], ["Employment Status"], ["Living Info"], ["My Priorities"], ["My Interests"]]
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.forDataOffersCell, for: indexPath)
            
        return setUpCell(cell: cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            self.performSegue(withIdentifier: Constants.Segue.dataStoreToEducationSegue, sender: self)
        } else if indexPath.section == 1 {
            
            self.performSegue(withIdentifier: Constants.Segue.dataStoreToInfoSegue, sender: self)
        } else if indexPath.section == 2 {
            
            self.performSegue(withIdentifier: Constants.Segue.dataStoreToEmploymentStatusSegue, sender: self)
        } else if indexPath.section == 3 {
            
            self.performSegue(withIdentifier: Constants.Segue.dataStoreToHouseholdSegue, sender: self)
        } else if indexPath.section == 4 {
            
            self.performSegue(withIdentifier: Constants.Segue.prioritiesSegue, sender: self)
        } else if indexPath.section == 5 {
            
            self.performSegue(withIdentifier: Constants.Segue.interestsSegue, sender: self)
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
        
        return cell
    }
    
}
