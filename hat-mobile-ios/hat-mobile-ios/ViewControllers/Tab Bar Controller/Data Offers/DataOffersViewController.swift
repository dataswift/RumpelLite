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

internal class DataOffersViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// All the offers available
    private var offers: [DataOfferObject] = []
    /// Filtered offers, used to feed the table view with data we want to show
    private var filteredOffers: [DataOfferObject] = []
    
    /// A view to show that app is loading, fetching data plugs
    private var loadingView: UIView = UIView()
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    /// A static let variable pointing to the AuthoriseUserViewController for checking if token is active or not
    private static let authoriseVC: AuthoriseUserViewController = AuthoriseUserViewController()
    
    /// The filter index, based on the selectionIndicatorView
    private var filterBy: Int = 0
    
    /// DataBuyer app token
    private var appToken: String?
    /// A string to hold the specific Merchant for data offers, if empty then hat provides offers from every merchant
    var specificMerchant: String = ""
    /// The preffered title for the view
    var prefferedTitle: String = "Data Offers"
    /// The preffered title for the info pop up message
    var prefferedInfoMessage: String = "Accept an offer to do a digital action, whether it’s to tweet something (fulfilled by your Twitter data), be somewhere (fulfilled by your location data) or run (fulfilled by Fitbit data). Get rewarded for your digital actions!"
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the UICollectionView
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// An IBOutlet for handling the available offers label in the selectionIndicatorView
    @IBOutlet private weak var availableOffersLabel: UILabel!
    /// An IBOutlet for handling the redeemed offers label in the selectionIndicatorView
    @IBOutlet private weak var redeemedOffersLabel: UILabel!
    /// An IBOutlet for handling the summary label in the selectionIndicatorView
    @IBOutlet private weak var summaryLabel: UILabel!
    /// An IBOutlet for handling the list offers label in the selectionIndicatorView
    @IBOutlet private weak var listOffersLabel: UILabel!
    
    /// An IBOutlet for handling the available offers UIView in the selectionIndicatorView
    @IBOutlet private weak var availableDataOffersView: UIView!
    /// An IBOutlet for handling the redeemed offers UIView in the selectionIndicatorView
    @IBOutlet private weak var redeemedDataOffersView: UIView!
    /// An IBOutlet for handling summary UIView in the selectionIndicatorView
    @IBOutlet private weak var summaryDataOffersView: UIView!
    /// An IBOutlet for handling the selectionIndicatorView UIView
    @IBOutlet private weak var selectionIndicatorView: UIView!
    /// An IBOutlet for handling the list offers UIView in the selectionIndicatorView
    @IBOutlet private weak var listOffersView: UIView!
    
    /// An IBOutlet for handling the info pop up UIButton
    @IBOutlet private weak var infoPopUpButton: UIButton!
    
    // MARK: - IBActions
    
    /**
     It slides the pop up view controller from the bottom of the screen
     
     - parameter sender: The object that calls this method
     */
    @IBAction func infoPopUp(_ sender: Any) {
        
        self.showInfoViewController(text: prefferedInfoMessage)
        self.infoPopUpButton.isUserInteractionEnabled = false
    }
    
    // MARK: - View controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.title = self.prefferedTitle
        
        self.addGestures()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // check token
        self.addChildViewController(DataOffersViewController.authoriseVC)
        DataOffersViewController.authoriseVC.checkToken(viewController: self)
        
        self.getOffers()
        
        if self.specificMerchant == "" {
            
            self.createClassicOKAlertWith(
                alertMessage: "Please note that data offers are under beta testing. During this time, the following offers are not allowed: \n Offers requesting for PIIs (personal identity identifiers) \n Offers with cash payments for data",
                alertTitle: "Heads up!",
                okTitle: "OK",
                proceedCompletion: {})
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: Constants.ImageNames.tealImage), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        super.viewWillTransition(to: size, with: coordinator)
        
        if self.isViewLoaded && (self.view.window != nil) {
            
            DispatchQueue.main.async {
                
                coordinator.animate(
                    alongsideTransition: nil,
                    completion: { _ in
                    
                        self.collectionView.setCollectionViewLayout(self.collectionView.collectionViewLayout, animated: true)
                    }
                )
            }
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Add gestures
    
    /**
     Adds the gestures to the 3 UIViews in the selectionIndicatorView
     */
    private func addGestures() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))
        let tapGesture3 = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))

        self.availableDataOffersView.addGestureRecognizer(tapGesture)
        self.redeemedDataOffersView.addGestureRecognizer(tapGesture1)
        self.summaryDataOffersView.addGestureRecognizer(tapGesture2)
        self.listOffersView.addGestureRecognizer(tapGesture3)
    }
    
    // MARK: - Get offers
    
    /**
     Gets offers from HAT
     */
    private func getOffers() {
        
        func merchantsReceived(merchants: [String], newUserToken: String?) {
            
            func applicationTokenReceived(_ appToken: String, renewedToken: String?) {
                
                func fetchedOffers(_ dataOffers: [DataOfferObject], renewedToken: String?) {
                    
                    if self.specificMerchant == "" {
                        
                        var filteredOffers: [DataOfferObject] = []
                        
                        for offer in dataOffers where offer.merchantCode == "databuyerpublic" {
                            
                            filteredOffers.append(offer)
                        }
                        
                        self.showOffers(filteredOffers)
                    } else {
                        
                        self.showOffers(dataOffers)
                    }
                    // remove the loading screen from the view
                    self.loadingView.removeFromSuperview()
                    KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedToken)
                }
                
                func failedToFetchOffers(error: DataPlugError) {
                    
                    // remove the loading screen from the view
                    self.loadingView.removeFromSuperview()
                    switch error {
                    case .noInternetConnection:
                        
                        self.createClassicOKAlertWith(
                            alertMessage: "You need internet access to access data plugs.",
                            alertTitle: "No internet connection",
                            okTitle: "OK",
                            proceedCompletion: {})
                    default:
                        
                        CrashLoggerHelper.dataPlugErrorLog(error: error)
                    }
                }
                
                self.appToken = appToken

                if specificMerchant == "" {
                    
                    HATDataOffersService.getAvailableDataOffers(
                        applicationToken: appToken,
                        merchants: merchants,
                        succesfulCallBack: fetchedOffers,
                        failCallBack: failedToFetchOffers)
                } else {
                    
                    HATDataOffersService.getAvailableDataOffers(
                        applicationToken: appToken,
                        merchants: [specificMerchant],
                        succesfulCallBack: fetchedOffers,
                        failCallBack: failedToFetchOffers)
                }
            }
            
            func failedToFetchApplicationToken(error: JSONParsingError) {
                
                // remove the loading screen from the view
                self.loadingView.removeFromSuperview()
                
                switch error {
                case .noInternetConnection:
                    
                    self.createClassicOKAlertWith(
                        alertMessage: "You need internet access to access data plugs.",
                        alertTitle: "No internet connection",
                        okTitle: "OK",
                        proceedCompletion: {})
                default:
                    
                    CrashLoggerHelper.JSONParsingErrorLog(error: error)
                }
            }
            
            HATService.getApplicationTokenFor(
                serviceName: Constants.ApplicationToken.DataBuyer.name,
                userDomain: self.userDomain,
                token: self.userToken,
                resource: Constants.ApplicationToken.DataBuyer.source,
                succesfulCallBack: applicationTokenReceived,
                failCallBack: failedToFetchApplicationToken)
        }
        
        // create loading pop up screen
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: self.view.frame.midX - 70, y: self.view.bounds.midY - 15, width: 140, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Getting data offers...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        
        HATDataOffersService.getMerchants(
            userToken: userToken,
            userDomain: userDomain,
            succesfulCallBack: merchantsReceived,
            failCallBack: { error in
                
                // remove the loading screen from the view
                self.loadingView.removeFromSuperview()
                
                switch error {
                case .noInternetConnection:
                    
                    self.createClassicOKAlertWith(
                        alertMessage: "You need internet access to access data plugs.",
                        alertTitle: "No internet connection",
                        okTitle: "OK",
                        proceedCompletion: {})
                default:
                    
                    CrashLoggerHelper.dataPlugErrorLog(error: error)
                }
            }
        )
    }
    
    // MARK: - Count offers
    
    /**
     Counts downloaded offers
     */
    private func countOffers() {
        
        var offersAvailable = 0
        var offersClaimed = 0
        var listOffers = 0
        
        _ = self.offers.map({
            if $0.claim.claimStatus == "" {
                
                offersAvailable += 1
            } else if $0.claim.claimStatus != "" {
                
                offersClaimed += 1
            }
            
            if ($0.claim.claimStatus == "completed" || $0.claim.claimStatus == "redeemed") && ($0.reward.rewardType == "Service" || $0.reward.rewardType == "Voucher") {
                
                listOffers += 1
            }
        })
        
        self.availableOffersLabel.text = String(describing: offersAvailable)
        self.redeemedOffersLabel.text = String(describing: offersClaimed)
        self.listOffersLabel.text = String(describing: listOffers)
        self.summaryLabel.text = "$"
    }
    
    // MARK: - Filter offers
    
    /**
     Filters the offers based on the index of the selectionIndicatorView
     
     - parameter filterBy: The index of the selectionIndicatorView
     */
    private func filterOffers(filterBy: Int) {
        
        var tempArray: [DataOfferObject] = []
        _ = self.offers.map({
            
            if filterBy == 0 && $0.claim.claimStatus == "" {
                
                tempArray.append($0)
            } else if filterBy == 1 && $0.claim.claimStatus != "" {
                
                tempArray.append($0)
            } else if filterBy == 3 && ($0.claim.claimStatus == "completed" || $0.claim.claimStatus == "redeemed") && ($0.reward.rewardType == "Service" || $0.reward.rewardType == "Voucher") {
                
                tempArray.append($0)
            }
        })
        
        self.filteredOffers = tempArray
    }
    
    /**
     Filters the offers based on the index of the selectionIndicatorView
     
     - parameter gesture: The UITapGestureRecognizer that triggered this method
     */
    @objc
    func filterCollectionView(gesture: UITapGestureRecognizer) {
        
        func animation(index: Int) {
            
            let indicatorWidth = self.selectionIndicatorView.frame.width
            
            if index == 0 {
                
                self.selectionIndicatorView.frame = CGRect(
                    x: self.availableDataOffersView.frame.midX - indicatorWidth / 2,
                    y: self.selectionIndicatorView.frame.origin.y,
                    width: indicatorWidth,
                    height: self.selectionIndicatorView.frame.height)
            } else if index == 1 {
                
                self.selectionIndicatorView.frame = CGRect(
                    x: self.redeemedDataOffersView.frame.midX - indicatorWidth / 2,
                    y: self.selectionIndicatorView.frame.origin.y,
                    width: indicatorWidth,
                    height: self.selectionIndicatorView.frame.height)
            } else if index == 2 {
                
                self.selectionIndicatorView.frame = CGRect(
                    x: self.summaryDataOffersView.frame.midX - indicatorWidth / 2,
                    y: self.selectionIndicatorView.frame.origin.y,
                    width: indicatorWidth,
                    height: self.selectionIndicatorView.frame.height)
            } else if index == 3 {
                
                self.selectionIndicatorView.frame = CGRect(
                    x: self.listOffersView.frame.midX - indicatorWidth / 2,
                    y: self.selectionIndicatorView.frame.origin.y,
                    width: indicatorWidth,
                    height: self.selectionIndicatorView.frame.height)
            }
            
            self.filterBy = index
            self.filterOffers(filterBy: index)
            self.collectionView.reloadData()
        }
        
        AnimationHelper.animateView(
            self.selectionIndicatorView,
            duration: 0.25,
            animations: {
                
                animation(index: (gesture.view?.tag)!)
            },
            completion: { _ in return }
        )
    }
    
    // MARK: - UIScrollView methods
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let translation = scrollView.panGestureRecognizer.translation(in: scrollView.superview!)
        if translation.y < 0 {
            
            // swipes from top to bottom of screen -> down
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            
            // swipes from bottom to top of screen -> up
            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Show offers
    
    /**
     The received offers from HAT
     
     - parameter dataOffers: The data offers downloaded from HAT
     */
    func showOffers(_ dataOffers: [DataOfferObject]) {
        
        self.offers = dataOffers
        self.filterOffers(filterBy: self.filterBy)
        self.countOffers()
        self.collectionView.reloadData()
    }
    
    // MARK: - Collection View functions
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.filterBy == 0 || self.filterBy == 1 {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.offerCell, for: indexPath) as? DataOffersCollectionViewCell {
                
                return cell.setUpCell(
                    cell: cell,
                    dataOffer: filteredOffers[indexPath.row],
                    completion: { [weak self] image in
                        
                        if let weakSelf = self {
                            
                            if weakSelf.filteredOffers.count > indexPath.row {
                                
                                weakSelf.filteredOffers[indexPath.row].image = image
                            }
                        }
                    }
                )
            }
        } else if self.filterBy == 3 {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.listDataOffersCell, for: indexPath) as? ListDataOffersCollectionViewCell {
                
                return cell.setUpCell(
                    cell: cell,
                    dataOffer: filteredOffers[indexPath.row],
                    completion: { [weak self] image in
                        
                        if let weakSelf = self {
                            
                            if weakSelf.filteredOffers.count > indexPath.row {
                                
                                weakSelf.filteredOffers[indexPath.row].image = image
                            }
                        }
                    }
                )
            }
        } else {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.summaryOfferCell, for: indexPath) as? DataOffersSummaryCollectionViewCell {
                
                return cell.setUpCell(cell: cell, index: indexPath.row, dataOffers: self.offers)
            }
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.offerCell, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let model = UIDevice.current.model
        if model == "iPhone" {
            
            let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            flow?.minimumInteritemSpacing = 10
            flow?.minimumLineSpacing = 10
            
            if self.filterBy == 2 {
                
                return CGSize(width: self.collectionView.frame.width - 40, height: 180)
            } else if self.filterBy == 3 {
                
                flow?.minimumInteritemSpacing = 0
                flow?.minimumLineSpacing = 0
                return CGSize(width: self.collectionView.frame.width, height: 130)
            }
            
            return CGSize(width: self.collectionView.frame.width - 40, height: 340)
        } else {
            
            let flow = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
            flow?.minimumInteritemSpacing = 10
            flow?.minimumLineSpacing = 10
            flow?.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
            
            if self.filterBy == 2 {
                
                return CGSize(width: self.collectionView.frame.width - 40, height: 180)
            } else if self.filterBy == 3 {
                
                flow?.minimumInteritemSpacing = 0
                flow?.minimumLineSpacing = 0
                return CGSize(width: self.collectionView.frame.width, height: 130)
            }
            
            return CGSize(width: (self.collectionView.frame.width - 40) / 2, height: 340)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.filterBy == 2 {
            
            return 3
        }
        
        return filteredOffers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        func continueOnOffer() {
            
            if self.filterBy != 2 {
                
                let cell = collectionView.cellForItem(at: indexPath)
                self.performSegue(withIdentifier: Constants.Segue.offerToOfferDetailsSegue, sender: cell)
            }
            
            KeychainHelper.setKeychainValue(key: "DataOfferPopUp", value: "true")
        }
        
        let result = KeychainHelper.getKeychainValue(key: "DataOfferPopUp")
            
        if result != "true" {
            
            self.createClassicOKAlertWith(
                alertMessage: "We are beta testing data offers from databuyers at databuyer.hubat.net. These offers are not real ones but its fun to test - do give us feedback at contact@hatdex.org",
                alertTitle: "Heads Up!",
                okTitle: "Got it!",
                proceedCompletion: continueOnOffer)
        } else {
            
            continueOnOffer()
        }
    }
    
    // MARK: - Remove pop up
    
    /**
     Hides pop up presented currently
     */
    @objc
    private func hidePopUp() {
        
        self.darkView?.removeFromSuperview()
        self.infoPopUpButton.isUserInteractionEnabled = true
    }
    
    // MARK: - Add blur View
    
    /**
     Adds blur to the view before presenting the pop up
     */
    private func addBlurToView() {
        
        self.darkView = AnimationHelper.addBlurToView(self.view)
    }
    
    /**
     Shows the pop up view controller with the info passed on
     
     - parameter text: A String to show in the view controller
     */
    private func showInfoViewController(text: String) {
        
        // set up page controller
        let textPopUpViewController = TextPopUpViewController.customInit(
            stringToShow: text,
            isButtonHidden: true,
            from: self.storyboard!)
        
        let calculatedHeight = textPopUpViewController!.getLabelHeight() + 130
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(
            frame: CGRect(
                x: self.view.frame.origin.x + 15,
                y: self.collectionView.frame.maxY,
                width: self.view.frame.width - 30,
                height: calculatedHeight),
            color: .teal,
            cornerRadius: 15)
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                // add the page view controller to self
                weakSelf.addBlurToView()
                weakSelf.addViewController(textPopUpViewController!)
                AnimationHelper.animateView(
                    textPopUpViewController?.view,
                    duration: 0.2,
                    animations: {() -> Void in
                        
                        textPopUpViewController?.view.frame = CGRect(
                            x: weakSelf.view.frame.origin.x + 15,
                            y: weakSelf.collectionView.frame.maxY + (0.35 * calculatedHeight) - calculatedHeight,
                            width: weakSelf.view.frame.width - 30,
                            height: calculatedHeight)
                    },
                    completion: { _ in return }
                )
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is DataOfferDetailsViewController && segue.identifier == Constants.Segue.offerToOfferDetailsSegue {
            
            navigationController?.isNavigationBarHidden = false
            
            if self.filterBy == 2 {
                
                if let cell = sender as? DataOffersSummaryCollectionViewCell {
                    
                    let cellIndexPath = self.collectionView.indexPath(for: cell)
                    if cellIndexPath?.row == 1 {
                        
                        func requestMoney() {
                            
                            func success(message: String, newUserToken: String?) {
                                
                                self.createClassicOKAlertWith(
                                    alertMessage: "Request sent",
                                    alertTitle: "Successful Request",
                                    okTitle: "OK",
                                    proceedCompletion: {}
                                )
                            }
                            
                            func error(error: DataPlugError) {
                                
                                self.createClassicOKAlertWith(
                                    alertMessage: "Please try again later",
                                    alertTitle: "An error has occured",
                                    okTitle: "OK",
                                    proceedCompletion: {})
                            }
                            
                            HATDataOffersService.redeemOffer(
                                appToken: self.appToken!,
                                succesfulCallBack: success,
                                failCallBack: error)
                        }
                        
                        self.createClassicAlertWith(
                            alertMessage: "If your cash balance is at least £20, you can use the button below to transfer your balance to your PayPal account",
                            alertTitle: "Request Transfer",
                            cancelTitle: "Cancel",
                            proceedTitle: "Request Transfer",
                            proceedCompletion: requestMoney,
                            cancelCompletion: {})
                    }
                }
            } else if let cell = sender as? UICollectionViewCell {
                
                weak var destinationVC = segue.destination as? DataOfferDetailsViewController

                let cellIndexPath = self.collectionView.indexPath(for: cell)
                destinationVC?.receivedOffer = self.filteredOffers[(cellIndexPath?.row)!]
            }
        }
    }

}
