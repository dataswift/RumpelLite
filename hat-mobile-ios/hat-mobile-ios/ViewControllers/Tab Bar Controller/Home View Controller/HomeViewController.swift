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
    
    /// A static let variable pointing to the AuthoriseUserViewController for checking if token is active or not
    private static let authoriseVC: AuthoriseUserViewController = AuthoriseUserViewController()
    
    /// The locations protocol
    private let location: UpdateLocations = UpdateLocations.shared
    
    /// A string to hold the specific Merchant for data offers, if empty then hat provides offers from every merchant
    private var specificMerchantForOffers: String = ""
    
    /// An object to hold the values needed to pass on to the next views for set up
    private var segueObjectValues: HomeScreenSegueObject = HomeScreenSegueObject()
    
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
        let model = UIDevice.current.model
        
        if model == "iPhone" {
            
            // in case of landscape show 3 tiles instead of 2
            if orientation == .landscapeLeft || orientation == .landscapeRight {
                
                return CGSize(width: UIScreen.main.bounds.width / 3, height: UIScreen.main.bounds.width / 3)
            }
            
            return CGSize(width: UIScreen.main.bounds.width / 2, height: UIScreen.main.bounds.width / 2)
        } else {
            
            // in case of landscape show 6 tiles instead of 4
            if orientation == .landscapeLeft || orientation == .landscapeRight {
                
                return CGSize(width: UIScreen.main.bounds.width / 6, height: UIScreen.main.bounds.width / 6)
            }
            
            return CGSize(width: UIScreen.main.bounds.width / 4, height: UIScreen.main.bounds.width / 4)
        }
        
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
        
        self.segueObjectValues = HomeScreenSegueObject.setUpPassingSegueValuesBy(name: self.tiles[indexPath.row].serviceName, viewController: self)
        
        if self.segueObjectValues.showAlert {
            
            self.createClassicOKAlertWith(
                alertMessage: "We are featuring GoodLoop - share your data to watch more relevant ads, all while contributing to a charity of your choice and also back to your HAT!",
                alertTitle: "Heads Up",
                okTitle: "OK",
                proceedCompletion: {
                    
                    self.segueObjectValues.specificMerchantForOffers = "goodloop"
                    self.segueObjectValues.titleToPassOnToTheNextView = "Feature Offers"
                    self.segueObjectValues.infoPopUpToPassOnToTheNextView = "We are featuring GoodLoop - share your data to watch more relevant ads, all while contributing to a charity of your choice and also back to your HAT!"
                    self.performSegue(withIdentifier: Constants.Segue.homeToDataOffers, sender: self)
                }
            )
        }
        
        if self.segueObjectValues.segueName != "" {
            
            self.performSegue(withIdentifier: self.segueObjectValues.segueName, sender: self)
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
        
        self.addChildViewController(HomeViewController.authoriseVC)
        HomeViewController.authoriseVC.checkToken(viewController: self)
        
        self.location.setUpLocationObject(self.location, delegate: UpdateLocations.shared)
        self.location.locationManager?.requestAlwaysAuthorization()
        
        // set up elements
        let usersHAT = userDomain.components(separatedBy: ".")[0]
        self.helloLabel.text = "Hello \(usersHAT)!"
        
        SystemStatusWrapperHelper.getSystemStatus(userToken: userToken, userDomain: userDomain, successRespond: self.updateRingProgressBar, failRespond: CrashLoggerHelper.JSONParsingErrorLogWithoutAlert)
        
        self.collectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        let result = KeychainHelper.getKeychainValue(key: Constants.Keychain.newUser)
        
        if result != Constants.Keychain.Values.setTrue {
            
            self.showInfoViewController( text: "")
            KeychainHelper.setKeychainValue(key: Constants.Keychain.newUser, value: Constants.Keychain.Values.setTrue)
        }
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
                y: self.view.frame.maxY,
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
                
                vc.prefferedTitle = self.segueObjectValues.titleToPassOnToTheNextView
                vc.prefferedInfoMessage = self.segueObjectValues.infoPopUpToPassOnToTheNextView
                vc.specificMerchant = self.segueObjectValues.specificMerchantForOffers
            }
        } else if segue.identifier == Constants.Segue.notesSegue {
            
            if let vc = segue.destination as? NotablesViewController {
                
                vc.prefferedTitle = self.segueObjectValues.titleToPassOnToTheNextView
                vc.prefferedInfoMessage = self.segueObjectValues.infoPopUpToPassOnToTheNextView
                vc.privateNotesOnly = true
                vc.prefferedCacheType = "notes"
            }
        } else if segue.identifier == Constants.Segue.homeToEditNoteSegue {
            
            if let vc = segue.destination as? ShareOptionsViewController {
                
                vc.prefferedTitle = self.segueObjectValues.titleToPassOnToTheNextView
                vc.prefferedInfoMessage = self.segueObjectValues.infoPopUpToPassOnToTheNextView
                vc.autoSharedNote = true
            }
        } else if segue.identifier == Constants.Segue.homeToDataPlugs {
            
            if let vc = segue.destination as? DataPlugsCollectionViewController {
                
                vc.prefferedInfoMessage = self.segueObjectValues.infoPopUpToPassOnToTheNextView
            }
        } else if segue.identifier == Constants.Segue.homeToDataStore {
            
            if let vc = segue.destination as? DataStoreTableViewController {
                
                vc.prefferedTitle = self.segueObjectValues.titleToPassOnToTheNextView
                vc.prefferedInfoMessage = self.segueObjectValues.infoPopUpToPassOnToTheNextView
            }
        } else if segue.identifier == Constants.Segue.phataSegue {
            
            if let vc = segue.destination as? PhataTableViewController {
                
                vc.prefferedTitle = self.segueObjectValues.titleToPassOnToTheNextView
                vc.prefferedInfoMessage = self.segueObjectValues.infoPopUpToPassOnToTheNextView
            }
        } else if segue.identifier == Constants.Segue.homeToForDataOffersSettingsSegue {
            
            if let vc = segue.destination as? DataStoreForDataOffersTableViewController {
                
                vc.prefferedTitle = self.segueObjectValues.titleToPassOnToTheNextView
                vc.prefferedInfoMessage = self.segueObjectValues.infoPopUpToPassOnToTheNextView
            }
        }
    }
    
}
