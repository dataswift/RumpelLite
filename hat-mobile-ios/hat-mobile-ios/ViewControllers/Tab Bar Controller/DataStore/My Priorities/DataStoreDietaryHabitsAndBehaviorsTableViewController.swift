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

internal class DataStoreDietaryHabitsAndBehaviorsTableViewController: UITableViewController, UserCredentialsProtocol {

    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["Food Shopping"], ["Hydrating Properly"], ["Cooking And Eating Healthier Meals"], ["Healthier Desserts"], ["Reducing Calories"]]
    
    private var surveyObjects: [SurveyObject] = []
    
    // MARK: - Auto generated methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
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
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.dietaryHabitsCell, for: indexPath) as? SurveyTableViewCell

        return self.setUpCell(cell: cell!, indexPath: indexPath)
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
        cell.setSelectedAnswer(3)
        return cell
    }
    
    func accessingHATTableFail(error: HATTableError) {
        
        CrashLoggerHelper.hatTableErrorLog(error: error)
    }
    
    private func getSurveyQuestionsAndAnswers() {
        
        func gotValues(jsonArray: [JSON], newToken: String?) {
            
            for json in jsonArray {
                
                self.surveyObjects.append(SurveyObject(from: json))
            }
        }
        
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.DietaryAnswers.source,
            scope: Constants.HATTableName.DietaryAnswers.name,
            parameters: ["take": "1", "orderBy": "dateUploaded", "ordering": "descending"],
            successCallback: gotValues,
            errorCallback: accessingHATTableFail)
    }

}
