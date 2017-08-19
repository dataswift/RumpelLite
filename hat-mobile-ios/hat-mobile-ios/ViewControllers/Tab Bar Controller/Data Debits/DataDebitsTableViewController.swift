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

internal class DataDebitsTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The received dataDebits from HAT
    private var dataDebits: [DataDebitObject] = []
    
    // MARK: - Auto generated methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.getDataDebits()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.dataDebits.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Constants.CellReuseIDs.dataDebitCell,
            for: indexPath) as? DataDebitTableViewCell

        return cell!.setUpCell(cell: cell!, dataDebit: dataDebits[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.createClassicOKAlertWith(
            alertMessage: "Data Debit cancellation and amendments have not yet been enabled",
            alertTitle: "",
            okTitle: "Ok",
            proceedCompletion: {
                
                tableView.deselectRow(at: indexPath, animated: true)
            }
        )
    }
    
    // MARK: - Get data debits
    
    /**
     Gets the available dataDebits from hat
     */
    private func getDataDebits() {
        
        func gotDataDebits(dataDebitsArray: [DataDebitObject], newToken: String?) {
            
            self.dataDebits = dataDebitsArray
            self.tableView.reloadData()
        }
        
        func failedGettingDataDebits(error: DataPlugError) {
            
            CrashLoggerHelper.dataPlugErrorLog(error: error)
        }
        
        HATDataDebitsService.getAvailableDataDebits(
            userToken: userToken,
            userDomain: userDomain,
            succesfulCallBack: gotDataDebits,
            failCallBack: failedGettingDataDebits)
    }

}
