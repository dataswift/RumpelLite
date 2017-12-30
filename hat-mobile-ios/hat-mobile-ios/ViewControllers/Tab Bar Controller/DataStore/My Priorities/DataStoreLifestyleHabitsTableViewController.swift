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

internal class DataStoreLifestyleHabitsTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Improve my Sleep Habits"], ["Manage my Stress"], ["Moderation And Balancing my Lifestyle"]]
    private let header: String = "Please indicate how important from 1 (not at all) to 5 (very much)"
    
    private var surveyObjects: [SurveyObject] = []
    
    private var loadingView: UIView?
    
    // MARK: - IBActions
    
    @IBAction func saveHabits(_ sender: Any) {
        
        func success() {
            
            DispatchQueue.main.async { [weak self] in
                
                self?.loadingView?.removeFromSuperview()
                self?.tableView.isUserInteractionEnabled = true
                _ = self?.navigationController?.popViewController(animated: true)
            }
        }
        
        DispatchQueue.main.async { [weak self] in
            
            guard let weakSelf = self else {
                
                return
            }
            weakSelf.tableView.isUserInteractionEnabled = false
            weakSelf.loadingView = UIView.createLoadingView(
                with: CGRect(x: (weakSelf.tableView?.frame.midX)! - 70, y: (weakSelf.tableView?.frame.midY)! - 15, width: 160, height: 30),
                color: .teal,
                cornerRadius: 15,
                in: weakSelf.view,
                with: "Saving HAT data...",
                textColor: .white,
                font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
            
            for index in weakSelf.sections.indices {
                
                var cell = weakSelf.tableView.cellForRow(at: IndexPath(row: 0, section: index)) as? SurveyTableViewCell
                
                if cell == nil {
                    
                    let indexPath = IndexPath(row: 0, section: index)
                    cell = weakSelf.tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.lifestyleHabitsCell, for: indexPath) as? SurveyTableViewCell
                    cell = weakSelf.setUpCell(cell: cell!, indexPath: indexPath) as? SurveyTableViewCell
                }
                
                if weakSelf.surveyObjects.count < index {
                    
                    weakSelf.surveyObjects.append(SurveyObject())
                }
                weakSelf.surveyObjects[index].answer = (cell?.getSelectedAnswer())!
            }
            
            var array: [Dictionary<String, Any>] = []
            for survey in weakSelf.surveyObjects {
                
                array.append(survey.toJSON())
            }
            
            LifestyleHabitsCachingWrapperHelper.postSurveyObject(
                surveyObjects: weakSelf.surveyObjects,
                userToken: weakSelf.userToken,
                userDomain: weakSelf.userDomain,
                successCallback: success,
                errorCallback: weakSelf.accessingHATTableFail)
        }
    }
    
    // MARK: - Auto generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.lifestyleHabitsCell, for: indexPath) as? SurveyTableViewCell
        
        return self.setUpCell(cell: cell!, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return header
    }
    
    // MARK: - Update cell
    
    /**
     Sets up the cell accordingly
     
     - parameter cell: The cell to set up
     - parameter indexPath: The index path of the cell
     
     - returns: The set up cell
     */
    func setUpCell(cell: SurveyTableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        cell.setQuestionInLabel(question: self.sections[indexPath.section][indexPath.row])
        if self.surveyObjects.count > indexPath.section {
            
            cell.setSelectedAnswer(self.surveyObjects[indexPath.section + indexPath.row].answer)
        } else {
            
            var surveyObject = SurveyObject()
            surveyObject.question = self.sections[indexPath.section][indexPath.row]
            
            self.surveyObjects.append(surveyObject)
        }
        
        return cell
    }
    
    // MARK: - Get Survey questions
    
    /**
     Logs the error with the fabric
     
     - parameter error: The HATTableError returned from hat
     */
    func accessingHATTableFail(error: HATTableError) {
        
        DispatchQueue.main.async { [weak self] in
            
            self?.tableView.isUserInteractionEnabled = false
            self?.loadingView?.removeFromSuperview()
            self?.createClassicOKAlertWith(
                alertMessage: "The was an error saving the data to HAT",
                alertTitle: "Error",
                okTitle: "OK",
                proceedCompletion: {})
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
    }
    
    /**
     Get questions from hat
     */
    private func getSurveyQuestionsAndAnswers() {
        
        func gotValues(jsonArray: [SurveyObject], newToken: String?) {
            
            DispatchQueue.main.async { [weak self] in
                
                guard let weakSelf = self else {
                    
                    return
                }
                weakSelf.tableView.isUserInteractionEnabled = true
                weakSelf.loadingView?.removeFromSuperview()
                
                if !jsonArray.isEmpty {
                    
                    weakSelf.surveyObjects.removeAll()
                    
                    for item in jsonArray {
                        
                        weakSelf.surveyObjects.append(item)
                    }
                    
                    weakSelf.tableView.reloadData()
                }
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
            
            weakSelf.loadingView?.removeFromSuperview()
            weakSelf.loadingView = UIView.createLoadingView(
                with: CGRect(x: midX - 70, y: midY - 15, width: 160, height: 30),
                color: .teal,
                cornerRadius: 15,
                in: weakSelf.view,
                with: "Loading HAT data...",
                textColor: .white,
                font: font)
        }
        
        LifestyleHabitsCachingWrapperHelper.getSurveyObject(
            userToken: userToken,
            userDomain: userDomain,
            cacheTypeID: "lifestyleHabits",
            successRespond: gotValues,
            failRespond: accessingHATTableFail)
    }
    
}
