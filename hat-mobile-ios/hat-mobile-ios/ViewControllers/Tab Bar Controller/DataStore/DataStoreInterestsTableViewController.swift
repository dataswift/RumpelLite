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
        ["Modern European", "Fusion", "Halal", "Chinese", "Thai", "Malaysian", "Vietnamese", "Japanese", "Italian", "Mediterranean", "Mexican", "International"],
        ["Wine", "Whiskey", "Vodka", "Beer", "Cocktails", "Non Alcoholic"],
        ["Games & Puzzles", "Film/Movies", "Series", "Music", "TV", "Gaming", "Sports"],
        ["Fitness", "Exercise", "Fashion And Styles", "Gardening and Landscaping", "Shopping", "Cooking and Recipes", "Travel", "Home furnishings", "Face and Body Care"],
        ["Computer Hardware", "Consumer electronics", "Programming", "Mobile Apps"]]
    /// The headers of the table view
    private let headers: [String] = ["Food",
                                    "Drinks",
                                    "Entertainment",
                                    "Lifestyle",
                                    "Technology"]
    
    /// The dictionary to send to hat
    private var interests: InterestsObject = InterestsObject(from: [
        "Modern European": 0,
        "Fusion": 0,
        "Halal": 0,
        "Chinese": 0,
        "Thai": 0,
        "Malaysian": 0,
        "Vietnamese": 0,
        "Japanese": 0,
        "Italian": 0,
        "Mexican": 0,
        "International": 0,
        "Wine": 0,
        "Whiskey": 0,
        "Vodka": 0,
        "Beer": 0,
        "Jin": 0,
        "Non Alcoholic": 0,
        "Games & Puzzles": 0,
        "Film/Movies": 0,
        "Series": 0,
        "Music": 0,
        "TV": 0,
        "Gaming": 0,
        "Sports": 0,
        "Fitness": 0,
        "Exercise": 0,
        "Fashion And Styles": 0,
        "Gardening and Landscaping": 0,
        "Shopping": 0,
        "Cooking and Recipes": 0,
        "Travel": 0,
        "Home furnishing": 0,
        "Face and Body Care": 0,
        "Computer Hardware": 0,
        "Consumer electronics": 0,
        "Programming": 0,
        "Mobile Apps": 0,
        "unixTimeStamp": SurveyObject.createUnixTimeStamp()])
    
    /// A variable for holding the loading UIView
    private var loadingView: UIView = UIView()
    
    // MARK: - IBActions
    
    /**
     Saves the values selected to the HAT
     
     - parameter sender: The object that calls this method
     */
    @IBAction func saveHabits(_ sender: Any) {
        
        func success() {
            
            self.tableView.isUserInteractionEnabled = true
            self.loadingView.removeFromSuperview()
            
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        self.tableView.isUserInteractionEnabled = false
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.tableView?.frame.midX)! - 70, y: (self.tableView?.frame.midY)! - 15, width: 160, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Saving HAT data...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)

        InterestsCachingWrapperHelper.postInterestObject(
            interestObject: self.interests,
            userToken: userToken,
            userDomain: userDomain,
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
        
        for (key, value) in self.interests.dictionary where key == cell.textLabel?.text && String(describing: value) == "1" {
            
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .checkmark
        self.interests.dictionary.updateValue(1, forKey: (cell?.textLabel?.text)!)
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        cell?.accessoryType = .none
        self.interests.dictionary.updateValue(0, forKey: (cell?.textLabel?.text)!)
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
        
        self.tableView.isUserInteractionEnabled = true
        self.loadingView.removeFromSuperview()
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    /**
     Get questions from hat
     */
    private func getSurveyQuestionsAndAnswers() {
        
        func gotValues(jsonArray: [InterestsObject], newToken: String?) {
            
            self.tableView.isUserInteractionEnabled = true
            self.loadingView.removeFromSuperview()
            
            if !jsonArray.isEmpty {
                
                self.interests = jsonArray[0]
                
                self.tableView.reloadData()
            }
        }
        
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
                with: "Loading HAT data...",
                textColor: .white,
                font: font)
        }

        InterestsCachingWrapperHelper.getInterestObject(
            userToken: userToken,
            userDomain: userDomain,
            cacheTypeID: "interests",
            successRespond: gotValues,
            failRespond: accessingHATTableFail)
    }
    
}
