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

/// The class responsible for the landing screen
internal class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The tiles to show
    private var tiles: [HomeScreenObject] = []
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    /// An UIViewController used for authorising user
    private var authoriseVC: AuthoriseUserViewController?
    
    /// The locations protocol
    private let location: UpdateLocations = UpdateLocations.shared
    
    /// A string to hold the specific Merchant for data offers, if empty then hat provides offers from every merchant
    private var specificMerchantForOffers: String = ""
    
    private var titleToPassOnToTheNextView: String = ""
    private var infoPopUpToPassOnToTheNextView: String = ""
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the circle progress bar view
    @IBOutlet private weak var ringProgressBar: RingProgressCircle!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// An IBOutlet for handling the hello label on the top of the screen
    @IBOutlet private weak var helloLabel: UILabel!
    
    // MARK: - IBActions
    
    /**
     Shows a pop up info about the data services
     
     - parameter sender: The object that called this method
     */
    @IBAction func showInfoButtonAction(_ sender: Any) {
        
        self.showInfoViewController(
            text: "Rumpel Lite's Data Services are all the neat things you can do with your HAT data. Pull your data in with Data Plugs, and make it useful to you with Data Services.")
    }
    
    // MARK: - Collection View methods
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Constants.CellReuseIDs.homeScreenCell,
            for: indexPath) as? HomeCollectionViewCell
        
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        
        return HomeCollectionViewCell.setUp(
            cell: cell!,
            indexPath: indexPath,
            object: self.tiles[indexPath.row],
            orientation: orientation)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.tiles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        // in case of landscape show 3 tiles instead of 2
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            
            return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
        }
        
        return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Constants.CellReuseIDs.homeHeader,
            for: indexPath) as? HomeHeaderCollectionReusableView {
            
                return headerView.setUp(stringToShow: "Data Services")
            }
                
        return collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: Constants.CellReuseIDs.homeHeader,
            for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if self.tiles[indexPath.row].serviceName == "Top Secret Logs" {
            
            self.titleToPassOnToTheNextView = "Top Secret Logs"
            self.infoPopUpToPassOnToTheNextView = "Daily log, diary and innermost thoughts can all go in here!"
            self.performSegue(withIdentifier: Constants.Segue.notesSegue, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "GEOME" {
            
            self.titleToPassOnToTheNextView = "GEOME"
            self.infoPopUpToPassOnToTheNextView = "Check back where you were by using the date picker!"
            self.performSegue(withIdentifier: Constants.Segue.locationsSegue, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "My Story" {
            
            self.titleToPassOnToTheNextView = "My Story"
            self.infoPopUpToPassOnToTheNextView = "Still work-in-progress, this is where you can see your social feed and notes."
            self.performSegue(withIdentifier: Constants.Segue.socialDataSegue, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Photo Viewer" {
            
            self.performSegue(withIdentifier: Constants.Segue.photoViewerSegue, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Social Media Control" {
            
            self.infoPopUpToPassOnToTheNextView = "Post something on social media (FB or Twitter) or on HATTERS bulletin board. Share for 1/7/14/30 days and it would be deleted when the note expires! Or delete it instantly at the shared location by moving the note to private. Add your location or a photo!"
            self.titleToPassOnToTheNextView = "Social Media Control"
            self.performSegue(withIdentifier: Constants.Segue.homeToEditNoteSegue, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "The calling card" {
            
            self.infoPopUpToPassOnToTheNextView = "Your PHATA is your public profile. Enable it to use it as a calling card!"
            self.titleToPassOnToTheNextView = "The calling card"
            self.performSegue(withIdentifier: Constants.Segue.phataSegue, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Total Recall" {
            
            self.infoPopUpToPassOnToTheNextView = "Your personal data store for all numbers and important things to remember"
            self.titleToPassOnToTheNextView = "Total Recall"
            self.performSegue(withIdentifier: Constants.Segue.homeToDataStore, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Gimme" {
            
            self.infoPopUpToPassOnToTheNextView = "Pull in your data with the HAT data Plugs"
            self.titleToPassOnToTheNextView = "Gimme"
            self.performSegue(withIdentifier: Constants.Segue.homeToDataPlugs, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Watch-eet" {
            
            self.infoPopUpToPassOnToTheNextView = "Accept an offer to curate personalised entertainment (videos, movies) for your data. Pick the curator who might have the best algorithms to entertain you. Keep your list to watch later! Watch-eet is currently work-in-progress. During this time, HAT owners will see all recommendations, without any matching of data in your HAT."
            self.titleToPassOnToTheNextView = "Watch-eet"
            self.specificMerchantForOffers = "rumpelwatch"
            self.performSegue(withIdentifier: Constants.Segue.homeToDataOffers, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Read-eet" {
            
            self.infoPopUpToPassOnToTheNextView = "Accept an offer to curate personalised news, books and other reading materials, matched with your personal data. Keep your list to read later. Read-eet is currently work-in-progress. During this time, HAT owners see all recommendations, without any matching of data in your HAT."
            self.titleToPassOnToTheNextView = "Read-eet"
            self.specificMerchantForOffers = "rumpelread"
            self.performSegue(withIdentifier: Constants.Segue.homeToDataOffers, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Do-eet" {
            
            self.infoPopUpToPassOnToTheNextView = "Accept an offer to do a digital action, whether it’s to tweet something (fulfilled by your Twitter data), be somewhere (fulfilled by your location data) or run (fulfilled by Fitbit data). Get rewarded for your digital actions!"
            self.titleToPassOnToTheNextView = "Do-eet"
            self.specificMerchantForOffers = "rumpeldo"
            self.performSegue(withIdentifier: Constants.Segue.homeToDataOffers, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Match Me" {
            
            self.titleToPassOnToTheNextView = "Match Me"
            self.infoPopUpToPassOnToTheNextView = "Fill up your preference profile so that it can be matched with products and services out there"
            self.performSegue(withIdentifier: Constants.Segue.homeToForDataOffersSettingsSegue, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Find your Form" {
            
            self.titleToPassOnToTheNextView = "Find your Form"
            self.specificMerchantForOffers = "rumpelforms"
            self.performSegue(withIdentifier: Constants.Segue.homeToDataOffers, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Go deep" {
            
            self.titleToPassOnToTheNextView = "Go deep"
            self.performSegue(withIdentifier: Constants.Segue.homeToGoDeepSegue, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "MadHATTERs" {
            
            UIApplication.shared.openURL(URL(string: "http://us12.campaign-archive2.com/home/?u=bf49285ca77275f68a5263b83&id=3ca9558266")!)
        } else if self.tiles[indexPath.row].serviceName == "HAT" {
            
            UIApplication.shared.openURL(URL(string: "http://mailchi.mp/hatdex/hat-news-pieces-of-art-earning-from-your-attention-and-reading-your-name-1017509")!)
        } else if self.tiles[indexPath.row].serviceName == "HATTERs" {
            
            UIApplication.shared.openURL(URL(string: "https://hatters.hubofallthings.com/community")!)
        } else if self.tiles[indexPath.row].serviceName == "Ideas" {
            
            UIApplication.shared.openURL(URL(string: "https://marketsquare.hubofallthings.com/ideas")!)
        } else if self.tiles[indexPath.row].serviceName == "BeMoji" {
            
            self.infoPopUpToPassOnToTheNextView = "Broadcast your mood. Pick an emoji and broadcast it!"
            self.titleToPassOnToTheNextView = "BeMoji"
            self.performSegue(withIdentifier: Constants.Segue.homeToEditNoteSegue, sender: self)
        } else if self.tiles[indexPath.row].serviceName == "Featured App" {
            
            self.createClassicOKAlertWith(
                alertMessage: "We are featuring GoodLoop - share your data to watch more relevant ads, all while contributing to a charity of your choice and also back to your HAT!",
                alertTitle: "Heads Up",
                okTitle: "OK",
                proceedCompletion: {
                    
                    self.specificMerchantForOffers = "goodloop"
                    self.performSegue(withIdentifier: Constants.Segue.homeToDataOffers, sender: self)
                }
            )
        }
    }
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.tiles = HomeScreenObject.setUpTilesForHomeScreen()
        
        self.ringProgressBar.ringColor = .white
        self.ringProgressBar.ringRadius = 45
        self.ringProgressBar.ringLineWidth = 4
        self.ringProgressBar.animationDuration = 0.2

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
        
        // pin header view of collection view to the top while scrolling
        (self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout)!.sectionHeadersPinToVisibleBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        self.ringProgressBar.isHidden = true
        
        func success(token: String?) {
            
            if token != "" && token != nil {
                
                KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: token!)
                KeychainHelper.setKeychainValue(key: Constants.Keychain.logedIn, value: Constants.Keychain.Values.setTrue)
                
                self.authoriseVC?.removeViewController()
                self.authoriseVC = nil
            }
        }
        
        func failed() {
            
            NotificationCenter.default.post(
                name: NSNotification.Name(Constants.NotificationNames.networkMessage),
                object: "Unauthorized. Please sign out and try again.")
            KeychainHelper.setKeychainValue(key: Constants.Keychain.logedIn, value: Constants.Keychain.Values.expired)
            
            self.authoriseVC = AuthoriseUserViewController.setupAuthoriseViewController(view: self.view)
            self.authoriseVC?.completionFunc = success
            // addauthoriseVCthe page view controller to self
            self.addViewController(self.authoriseVC!)
        }
        
        // reset the stack to avoid allowing back
        let result = KeychainHelper.getKeychainValue(key: Constants.Keychain.logedIn)
        
        if result == "false" || userDomain == "" || userToken == "" {
            
            if let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                
                self.navigationController?.pushViewController(loginViewController, animated: false)
            }
        // user logged in, set up view
        } else {
            
            self.location.setUpLocationObject(self.location, delegate: UpdateLocations.shared)
            self.location.locationManager?.requestAlwaysAuthorization()
            
            // set up elements
            let usersHAT = userDomain.components(separatedBy: ".")[0]
            self.helloLabel.text = "Hello \(usersHAT)!"
            
            // check if the token has expired
            HATAccountService.checkIfTokenExpired(
                token: userToken,
                expiredCallBack: failed,
                tokenValidCallBack: success,
                errorCallBack: self.createClassicOKAlertWith)
            
            self.collectionView?.reloadData()
        }
        
        HATService.getSystemStatus(
            userDomain: userDomain,
            authToken: userToken,
            completion: updateRingProgressBar,
            failCallBack: CrashLoggerHelper.JSONParsingErrorLogWithoutAlert)
        
        self.collectionView.reloadData()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        self.collectionView?.reloadData()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Show pop up screens
    
    /**
     Shows newbie screens
     */
    private func showNewbieScreens() {
        
        // set up the created page view controller
        if let pageViewController = self.storyboard!.instantiateViewController(withIdentifier: "firstTimeOnboarding") as? FirstOnboardingPageViewController {
            
            pageViewController.view.createFloatingView(
                frame: CGRect(
                        x: self.view.frame.origin.x + 15,
                        y: self.view.frame.origin.x + 15,
                        width: self.view.frame.width - 30,
                        height: self.view.frame.height - 30),
                color: .teal,
                cornerRadius: 15)
            
            // add the page view controller to self
            self.addViewController(pageViewController)
            self.addBlurToView()
        }
    }
    
    /**
     Shows the pop up view controller with the info passed on
     
     - parameter text: A String to show in the view controller
     */
    private func showInfoViewController(text: String) {
        
        // set up page controller
        let imagePopUpPageViewController = ImagePopUpViewController.customInit(from: self.storyboard!)
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        imagePopUpPageViewController?.view.createFloatingView(
            frame: CGRect(
                x: self.view.frame.origin.x + 15,
                y: self.collectionView.frame.maxY,
                width: self.view.frame.width - 30,
                height: self.view.frame.height),
            color: .teal,
            cornerRadius: 15)
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                // add the page view controller to self
                weakSelf.addBlurToView()
                weakSelf.addViewController(imagePopUpPageViewController!)
                AnimationHelper.animateView(
                    imagePopUpPageViewController?.view,
                    duration: 0.2,
                    animations: {() -> Void in
                    
                        imagePopUpPageViewController?.view.frame = CGRect(
                            x: weakSelf.view.frame.origin.x + 15,
                            y: weakSelf.view.frame.origin.y + 60,
                            width: weakSelf.view.frame.width - 30,
                            height: weakSelf.view.frame.height - 50)
                    },
                    completion: { _ in return }
                )
            }
        }
    }

    // MARK: - Remove pop up
    
    /**
     Hides pop up presented currently
     */
    @objc
    private func hidePopUp() {
        
        self.darkView?.removeFromSuperview()
        self.tabBarController?.tabBar.isUserInteractionEnabled = true
    }
    
    // MARK: - Add blur View
    
    /**
     Adds blur to the view before presenting the pop up
     */
    private func addBlurToView() {
        
        self.darkView = AnimationHelper.addBlurToView(self.view)
    }
    
    // MARK: - Update ring progress bar
    
    /**
     Updates the system info on the top of the home screen view controller
     
     - parameter data: The objects received from the server
     */
    private func updateRingProgressBar(from data: [HATSystemStatusObject], renewedUserToken: String?) {
        
        if !data.isEmpty {
            
            self.helloLabel.text = "Hello \(userDomain.components(separatedBy: ".")[0])!"
            
            self.ringProgressBar.isHidden = false

            var attributedString = NSAttributedString(string: self.helloLabel.text! + "\n")
            self.helloLabel.text = attributedString.combineWith(
                attributedText: NSAttributedString(string: "Total space \(data[2].kind.metric) \(data[2].kind.units!)")).string
            attributedString = NSAttributedString(string: self.helloLabel.text! + "\n")
            self.helloLabel.text = attributedString.combineWith(
                attributedText: NSAttributedString(string: "Used space \(String(describing: Int(Float(data[4].kind.metric)!.rounded()))) \(data[4].kind.units!)")).string
            
            let fullCircle = 2.0 * CGFloat(Double.pi)
            self.ringProgressBar.startPoint = -0.25 * fullCircle
            self.ringProgressBar.animationDuration = 0.2
            
            let endPoint = CGFloat(max(Float(data[6].kind.metric)!, 1.0)) / 100
            
            self.ringProgressBar.endPoint = (endPoint * fullCircle) + self.ringProgressBar.startPoint
            
            self.ringProgressBar.updateCircle(end: endPoint, animate: 0, removePreviousLayer: true)
        }
        
        // refresh user token
        KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.homeToDataOffers {
            
            if let vc = segue.destination as? DataOffersViewController {
                
                vc.prefferedTitle = self.titleToPassOnToTheNextView
                vc.specificMerchant = self.specificMerchantForOffers
            }
        } else if segue.identifier == Constants.Segue.notesSegue {
            
            if let vc = segue.destination as? NotablesViewController {
                
                vc.prefferedTitle = self.titleToPassOnToTheNextView
                vc.privateNotesOnly = true
            }
        } else if segue.identifier == Constants.Segue.homeToEditNoteSegue {
            
            if let vc = segue.destination as? ShareOptionsViewController {
                
                vc.prefferedTitle = self.titleToPassOnToTheNextView
                vc.autoSharedNote = true
            }
        } else if segue.identifier == Constants.Segue.homeToDataPlugs {
            
            if let vc = segue.destination as? DataPlugsCollectionViewController {
                
                vc.prefferedTitle = self.titleToPassOnToTheNextView
            }
        } else if segue.identifier == Constants.Segue.homeToDataStore {
            
            if let vc = segue.destination as? DataStoreTableViewController {
                
                vc.prefferedTitle = self.titleToPassOnToTheNextView
            }
        } else if segue.identifier == Constants.Segue.phataSegue {
            
            if let vc = segue.destination as? PhataTableViewController {
                
                vc.prefferedTitle = self.titleToPassOnToTheNextView
            }
        } else if segue.identifier == Constants.Segue.homeToForDataOffersSettingsSegue {
            
            if let vc = segue.destination as? DataStoreForDataOffersTableViewController {
                
                vc.prefferedTitle = self.titleToPassOnToTheNextView
                vc.prefferedInfoMessage = self.infoPopUpToPassOnToTheNextView
            }
        }
    }
    
}
