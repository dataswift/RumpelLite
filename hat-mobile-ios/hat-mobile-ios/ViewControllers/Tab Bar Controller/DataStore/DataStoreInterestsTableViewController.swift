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

internal class DataStoreInterestsTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [
        ["Modern European", "Fusion", "Halal", "Chinese", "Thai", "Malaysian", "Vietnamese", "Japanese", "Italian", "Mexican", "Mediterranean", "Mexican", "International"],
        ["Wine", "Whisky", "Vodka", "Beer", "Jin", "Non Alcoholic"],
        ["Games & Puzzles", "Film/Movies", "Series", "Music", "TV", "Gaming", "Sports"],
        ["Fitness", "Exercise", "Fashion And Styles", "Gardening and Landscaping", "Shopping", "Cooking and Recipes", "Travel", "Home furnishings", "Face and Body Care"],
        ["Computer Hardware", "Consumer electronics", "Programming", "Mobile Apps"]]
    private let headers: [String] = ["Food",
                                    "Drinks",
                                    "Entertainment",
                                    "Lifestyle",
                                    "Technology"]
    
    private var selectedItems: [String] = []
    
    // MARK: - IBActions
    
    @IBAction func saveHabits(_ sender: Any) {
        
        func success(json: JSON, newToken: String?) {
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.Interests.source,
            dataPath: Constants.HATTableName.Interests.name,
            parameters: ["selecteditems": selectedItems,
                         "unixTimeStamp": SurveyObject.createUnixTimeStamp()],
            successCallback: success,
            errorCallback: accessingHATTableFail)
    }
    
    // MARK: - Auto generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.tableView.allowsMultipleSelection = true

        self.getSurveyQuestionsAndAnswers()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.sections[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.interestsCell, for: indexPath)
        
        cell.selectionStyle = .none
        cell.textLabel?.text = self.sections[indexPath.section][indexPath.row]
        cell.accessoryType = .none
        
        for item in self.selectedItems where item == cell.textLabel?.text {
            
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .checkmark
        self.selectedItems.append((cell?.textLabel?.text)!)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .none
        self.selectedItems.removeThe(string: (cell?.textLabel?.text)!)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    // MARK: - Get Survey questions
    
    /**
     Logs the error with the fabric
     
     - parameter error: The HATTableError returned from hat
     */
    func accessingHATTableFail(error: HATTableError) {
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    /**
     Get questions from hat
     */
    private func getSurveyQuestionsAndAnswers() {
        
        func gotValues(jsonArray: [JSON], newToken: String?) {
            
            if !jsonArray.isEmpty {
                
                self.selectedItems.removeAll()
                
                if let array = jsonArray[0].dictionary?["data"]?["selecteditems"].array {
                    
                    for item in array {
                        
                        self.selectedItems.append(item.stringValue)
                    }
                }
                
                for (section, category) in self.sections.enumerated() {
                    
                    for (row, item) in category.enumerated() {
                        
                        for selectedItem in self.selectedItems where selectedItem == item {
                            
                            let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: section))
                            
                            cell?.accessoryType = .checkmark
                        }
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.Interests.source,
            scope: Constants.HATTableName.Interests.name,
            parameters: ["take": "1", "orderBy": "unixTimeStamp", "ordering": "descending"],
            successCallback: gotValues,
            errorCallback: accessingHATTableFail)
    }
    
}
