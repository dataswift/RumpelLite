/** Copyright (C) 2016 HAT Data Exchange Ltd
 * SPDX-License-Identifier: AGPL-3.0
 *
 * This file is part of the Hub of All Things project (HAT).
 *
 * RumpelLite is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License
 * as published by the Free Software Foundation, version 3 of
 * the License.
 *
 * RumpelLite is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
 * the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General
 * Public License along with this program. If not, see
 * <http://www.gnu.org/licenses/>.
 */

import UIKit
import MapKit

// MARK: Class

/// All Viewcontrollers ectend this class. Contain common functions
class BaseViewController: UIViewController {

    // MARK: - Get storyboard
    
    /**
     Get Main storyboard reference
     
     - returns: UIStoryboard
     */
    func getMainStoryboard() -> UIStoryboard {
        
        return UIStoryboard.init(name: "Main", bundle: nil)
    }
    
    // MARK: - Sync functions

    /**
     Gets the last successful sync count from preferences
     
     - returns: Int
     */
    func getSuccessfulSyncCount() -> Int {
        
        // get standard user defaults
        let preferences = UserDefaults.standard
        
        // returns an integer if the key existed, or 0 if not.
        let successfulSyncCount:Int = preferences.integer(forKey: Constants.Preferences.SuccessfulSyncCount)
        
        return successfulSyncCount
    }
    
    /**
     Gets the last successful sync count from preferences
     
     - returns: The date of last successful sync. Optional
     */
    func getLastSuccessfulSyncDate() -> Date! {
        
        // get standard user defaults
        let preferences = UserDefaults.standard
        
        // search for the particular key, if found return it
        if let successfulSyncDate:Date = preferences.object(forKey: Constants.Preferences.SuccessfulSyncDate) as? Date {
            
            return successfulSyncDate
        }
        
        return nil
    }
    
    // MARK: - Create Alert function

    /**
     Presents a common UI alert dialog.
     
     - parameter title: The desired title for the Alert
     - parameter message: The desired message for the Alert
     */
    func presentUIAlertOK(_ title: String, message: String) -> Void {
        
        // create the alert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: NSLocalizedString("ok_label", comment:  "ok"), style: UIAlertActionStyle.default, handler: nil))
        // present the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Handle app state changes
    
    /**
     When app entered background

     - parameter notification: The Notification object that calls this method
     */
    func didEnterBackgroundNotification(_ notification: Notification) {
        
        //do stuff
    }

    /**
     When app becomes active
     
     - parameter notification: The Notification object that calls this method
     */
    func didBecomeActiveNotification(_ notification: Notification) {
        
        //do stuff
        if !Helper.TheUserHATDomain().isEmpty {
            
        }
    }
    
    // MARK: - Auto generated functions
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
