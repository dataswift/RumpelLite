## Overview
Rumpel Lite is the dashboard for your HAT on iOS. What you can do with Rumpel Lite:

• Download and configure a HAT - private, personal data containers for storing consumer information generated on the internet
• Securely store and maintain your own personal information
• Gather and capture information that's created about you by internet services like Facebook and Twitter
• Monitor and retain iOS sensor data about your location
• Store and publish text-based notes and updates

#### Requirements
Xcode build 9.0+. Requires iOS SDK 9.0+ and Swift 4.0+

### Installing and Running the Demo app
#### Install
Clone (using SSH) the repository to install the demo app (including any cocoapods) to your local machine

1. Create a new folder
2. Clone the app to the folder. While in the new folder, open a cmd terminal and run the following: 
```sh
git clone git@github.com:Hub-of-all-Things/RumpelLite.git
```

Once complete, the structure will be as follows:

```
[your project folder]
│
└───hat-mobile-ios
    │   README.md
    │
    ├───hat-mobile-ios
    │   │   ...
    │
    ├───hat-mobile-iosTests
    │   │   ...
    │
    ├───hat-mobile-iosUITests
    │   │   ...
    │
    └───Pods
    │   │   ...
    │
    └───hat-mobile-ios.xcworkspace
    
```

#### Run
1. Navigate to the hat-mobile-ios.xcworkspace file (see project tree above). This is a workspace file
2. Double click to open in Xcode
3. Click Run (⌘R)


#### Notes
1. If you need to create SSH keys, https://help.github.com/articles/generating-an-ssh-key/
2. The app does not require cocoapods to be installed 

#### Location Notes
1. locationManager.distanceFilter = kCLDistanceFilterNone (settings if using deferring updates)
2. locationManager.desiredAccuracy = [change in settings]
3. locationManager.requestAlwaysAuthorization()
4. locationManager.allowDeferredLocationUpdatesUntilTraveled([change in settings], timeout: [change in settings])
5. See Apple documentation, https://developer.apple.com/library/ios/documentation/CoreLocation/Reference/CLLocationManager_Class/index.html#//apple_ref/occ/instm/CLLocationManager/allowDeferredLocationUpdatesUntilTraveled:timeout:

#### Troubleshooting
If there are Xcode errors. Try the following:

1. Make sure you 'clean' the project (Xcode -> Product -> Clean) or (⇧⌘K)
2. Delete the Derived Data folder for the project. While in Xcode, go to 'Window -> Projects'. hat-mobile-ios will be highlighted. Go ahead and click 'Delete...'. Confirm deletion.
