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
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {
    
    var window: UIWindow?
    var deferringUpdates:Bool = false;
    
    /// Load the LocationManager
    lazy var locationManager: CLLocationManager! = {
        let locationManager = CLLocationManager()
        locationManager.desiredAccuracy = Helper.GetUserPreferencesAccuracy()
        locationManager.distanceFilter = Helper.GetUserPreferencesDistance()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestAlwaysAuthorization()
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.activityType = CLActivityType.otherNavigation /* see https://developer.apple.com/reference/corelocation/clactivitytype */
        return locationManager
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // if app was closed by iOS (low mem, etc), then receives a location update, and respawns your app, letting it know it respawned due to a location service
        if launchOptions?[UIApplicationLaunchOptionsKey.location] != nil {
            startUpdatingLocation()
            
            // DEBUG-LOGGING
            NSLog("DEBUG-LOGGING: AppDelegate launchOptions UIApplicationLaunchOptionsKey.location")

            return true
        }
        
        // register for user notifications
        let notificationSettings = UIUserNotificationSettings(types: [.alert, .sound], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        
        /* we already have a hat_domain, ie. can skip the login screen? */
        if !Helper.TheUserHATDomain().isEmpty {
            /* Go to the map screen. */
            let nav: UINavigationController = window?.rootViewController as! UINavigationController
            let storyboard = UIStoryboard.init(name: "Main", bundle: nil)
            let vc: MapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
            nav.setViewControllers([vc], animated: false)
        } else {
            /* Just fall through to go to the login screen as per the storyboard. */
        }
        
        
        self.window?.tintColor = Constants.Colours.AppBase
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // cancel all notifications
        UIApplication.shared.cancelAllLocalNotifications()
        
        // add new
        let localNotification:UILocalNotification = UILocalNotification()
        localNotification.alertAction = NSLocalizedString("sync_reminder_title", comment:  "title")
        localNotification.alertBody = NSLocalizedString("sync_reminder_message", comment:  "message")
        
        // date
        
        let timeInterval:TimeInterval = Helper.FutureTimeInterval.init(days: Double(3), timeType: Helper.TimeType.future).interval
        let futureDate = Date().addingTimeInterval(timeInterval) // e.g. 3 days from now
        
        localNotification.fireDate = futureDate
        localNotification.timeZone = TimeZone.current
        localNotification.soundName = UILocalNotificationDefaultSoundName
        
        UIApplication.shared.scheduleLocalNotification(localNotification)
        
        // DEBUG-LOGGING
        NSLog("DEBUG-LOGGING: AppDelegate applicationDidEnterBackground")
        
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // purge old data
        purgeUsingPredicate()
        
        // stopUpdatingLocation
        if let manager:CLLocationManager = locationManager
        {
            manager.stopUpdatingLocation()
            NSLog("Delegate stopUpdatingLocation");
        }
        
        // DEBUG-LOGGING
        NSLog("DEBUG-LOGGING: AppDelegate applicationDidBecomeActive")
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // DEBUG-LOGGING
        NSLog("DEBUG-LOGGING: AppDelegate applicationWillTerminate")
    }
    
    /*
     Callback handler oAuth
     */
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let urlHost:String = url.host
        {
            if urlHost == Constants.Auth.LocalAuthHost {
                let notification = Notification.Name(Constants.Auth.NotificationHandlerName)
                NotificationCenter.default.post(name: notification, object: url)
            }
        }
        
        return true
    }
    
    
    /**
     Check if we need to purge old data. 7 Days
     */
    func purgeUsingPredicate() -> Void {
        
        let lastWeek = Date().addingTimeInterval(Helper.FutureTimeInterval.init(days: Constants.PurgeData.OlderThan, timeType: Helper.TimeType.past).interval)
        let predicate = NSPredicate(format: "dateAdded <= %@", lastWeek as CVarArg)
        
        // use _ to get rid of result is unused warnings
        _ = RealmHelper.Purge(predicate)
        
    }
    
    
    /**
     The CLLocationManagerDelegate delegate
     Called when location update changes
     
     - parameter manager:   The CLLocation manager used
     - parameter locations: Array of locations
     */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        // get location
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        // DEBUG-LOGGING
        NSLog("DEBUG-LOGGING: AppDelegate. Location with no filtering. Lat: %f, Lng: %f, Acc: %f", latestLocation.coordinate.latitude, latestLocation.coordinate.longitude, latestLocation.horizontalAccuracy)
        NSLog("DEBUG-LOGGING: AppDelegate. Desired Accuracy: %f", locationManager.desiredAccuracy)

        
        // test that the horizontal accuracy does not indicate an invalid measurement
        if (latestLocation.horizontalAccuracy < 0)
        {
            return
        }
        // check we have a measurement that meets our requirements,
        if (latestLocation.horizontalAccuracy <= locationManager.desiredAccuracy) {
            let taskID = beginBackgroundUpdateTask()
            
            DispatchQueue.global().async {
                _ = RealmHelper.AddData(Double(latestLocation.coordinate.latitude), longitude: Double(latestLocation.coordinate.longitude), accuracy: Double(latestLocation.horizontalAccuracy))
                
                self.endBackgroundUpdateTask(taskID: taskID)
            }
        }
        
        /**
         *  Only call one. Calling again will disable it
         defer updates until a distance or period of time
         */
        if (!deferringUpdates)
        {
            // if we are deferring, the distanceFilter = kCLDistanceFilterNone
            //locationManager.distanceFilter = kCLDistanceFilterNone
            // get distance and time settings
            let distance: CLLocationDistance = Helper.GetUserPreferencesDeferredDistance()
            let time:TimeInterval = Helper.GetUserPreferencesDeferredTimeout()
            
            manager.allowDeferredLocationUpdates(untilTraveled: distance, timeout: time)
            
            deferringUpdates = true;
        }
        
    }
    
    //didFinishDeferredUpdatesWithError:
    func locationManager(_ manager: CLLocationManager, didFinishDeferredUpdatesWithError error: Error?) {
        // Stop deferring updates
        self.deferringUpdates = false
    }
    
    
    // background task
    func beginBackgroundUpdateTask() -> UIBackgroundTaskIdentifier {
        return UIApplication.shared.beginBackgroundTask(expirationHandler: {})
    }
    
    func endBackgroundUpdateTask(taskID: UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(taskID)
    }
    
    func startUpdatingLocation() -> Void {
        /*
         If not authorised, we can ignore.
         Onve user us logged in and has accepted the authorization, this will always be true
         */
        if let manager:CLLocationManager = locationManager
        {
            manager.startUpdatingLocation()
            NSLog("Delegate startUpdatingLocation");
            
            // DEBUG-LOGGING
            NSLog("DEBUG-LOGGING: AppDelegate startUpdatingLocation")

        }else{
            // DEBUG-LOGGING
            NSLog("DEBUG-LOGGING: AppDelegate startUpdatingLocation. Cannot get manager reference")
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error)
    {
        // DEBUG-LOGGING
        NSLog("DEBUG-LOGGING: AppDelegate locationManager didFailWithError: %@", error.localizedDescription)
    }
    
}

