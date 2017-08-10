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

internal class NotificationsTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [[""], [""]]
    /// The headers of the table view
    private let headers: [String] = ["New", "Past"]
    
    private var dexAppToken: String = ""
    
    private var newNotifications: [NotificationObject] = []
    private var pastNotifications: [NotificationObject] = []
    private var allNotifications: [NotificationObject] = []
    private var selectedNotification: NotificationObject?
    
    // MARK: - Auto generated functions

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.getDexApplicationToken()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func getNotifications(appToken: String, newToken: String?) {
        
        func notificationsReceived(notifications: [NotificationObject], renewedUserToken: String?) {
            
            for notification in notifications {
                
                if notification.read != nil {
                    
                    self.pastNotifications.append(notification)
                } else {
                    
                    self.newNotifications.append(notification)
                }
            }
            self.allNotifications = notifications
            self.tableView.reloadData()
            KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
        }
        
        func notificationsError(error: HATTableError) {
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
        
        self.dexAppToken = appToken
        
        HATNotificationsService.getHATNotifications(
            appToken: appToken,
            successCallback: notificationsReceived,
            errorCallback: notificationsError)
    }
    
    func getDexApplicationToken() {
        
        func error(error: JSONParsingError) {
            
            CrashLoggerHelper.JSONParsingErrorLog(error: error)
        }
        
        HATService.getApplicationTokenFor(
            serviceName: Constants.ApplicationToken.Dex.name,
            userDomain: userDomain,
            token: userToken,
            resource: Constants.ApplicationToken.Dex.source,
            succesfulCallBack: getNotifications,
            failCallBack: error)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            
            return self.newNotifications.count
        }
        
        return self.pastNotifications.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section < self.headers.count {
            
            return self.headers[section]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.notificationsCell, for: indexPath) as? NotificationsTableViewCell

        cell?.accessoryType = .disclosureIndicator
        
        if indexPath.section == 0 {
            
            cell?.setTitleInLabel("From DEX")
            cell?.setDescriptionInLabel(self.newNotifications[indexPath.row].notice.message)
            let date = FormatterHelper.formatDateStringToUsersDefinedDate(
                date: self.newNotifications[indexPath.row].notice.dateCreated,
                dateStyle: .short,
                timeStyle: .none)
            cell?.setDateInLabel(date)
            self.selectedNotification = self.newNotifications[indexPath.row]
        } else {
            
            cell?.setTitleInLabel("From DEX")
            cell?.setDescriptionInLabel(self.pastNotifications[indexPath.row].notice.message)
            let date = FormatterHelper.formatDateStringToUsersDefinedDate(
                date: self.pastNotifications[indexPath.row].notice.dateCreated,
                dateStyle: .short,
                timeStyle: .none)
            cell?.setDateInLabel(date)
            self.selectedNotification = self.pastNotifications[indexPath.row]
        }

        return cell!
    }
    
    private func markNotificationAsRead(notification: NotificationObject) {
        
        func success(result: Bool, newToken: String?) {
            
            print(result)
        }
        
        func error(error: HATTableError) {
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
        
        HATNotificationsService.markNotificationAsRead(
            appToken: self.dexAppToken,
            notificationID: String(describing: notification.notice.noticeID),
            successCallback: success,
            errorCallback: error)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == 0 {
            
            self.selectedNotification = self.newNotifications[indexPath.row]

            self.markNotificationAsRead(notification: self.selectedNotification!)
        } else {
            
            self.selectedNotification = self.pastNotifications[indexPath.row]
        }
        
        self.performSegue(withIdentifier: Constants.Segue.notificationDetailsSegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.notificationDetailsSegue {
            
            // pass data to next view
            if let detailsVC = segue.destination as? NotificationDetailsViewController {
                
                detailsVC.notificationToShow = self.selectedNotification
            }
        }
    }

}
