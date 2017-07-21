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
    
    private var offers: [DataOfferObject] = []
    private var filteredOffers: [DataOfferObject] = []
    
    private var appToken: String?
    private var filterBy: Int = 0
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var collectionView: UICollectionView!
    
    @IBOutlet private weak var availableOffersLabel: UILabel!
    @IBOutlet private weak var redeemedOffersLabel: UILabel!
    @IBOutlet private weak var summaryLabel: UILabel!
    
    @IBOutlet private weak var availableDataOffersView: UIView!
    @IBOutlet private weak var redeemedDataOffersView: UIView!
    @IBOutlet private weak var summaryDataOffersView: UIView!
    @IBOutlet private weak var selectionIndicatorView: UIView!
    
    // MARK: - View controller functions
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))
        let tapGesture1 = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))
        let tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(filterCollectionView(gesture:)))
        
        self.availableDataOffersView.addGestureRecognizer(tapGesture)
        self.redeemedDataOffersView.addGestureRecognizer(tapGesture1)
        self.summaryDataOffersView.addGestureRecognizer(tapGesture2)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        func applicationTokenReceived(_ appToken: String, renewedToken: String?) {
            
            func fetchedOffers(_ dataOffers: [DataOfferObject], renewedToken: String?) {
                
                self.showOffers(dataOffers)
                _ = KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedToken)
            }
            
            func failedToFetchOffers(error: DataPlugError) {
                
                print(error)
            }
            
            self.appToken = appToken
            HATDataOffersService.getAvailableDataOffers(applicationToken: appToken, succesfulCallBack: fetchedOffers, failCallBack: failedToFetchOffers)
        }
        
        func failedToFetchApplicationToken(error: JSONParsingError) {
            
            print(error)
        }
        
        HATService.getApplicationTokenFor(serviceName: "DataBuyer", userDomain: self.userDomain, token: self.userToken, resource: "https://databuyer.hubofallthings.com/", succesfulCallBack: applicationTokenReceived, failCallBack: failedToFetchApplicationToken)
    }
    
    private func countOffers() {
        
        var offersAvailable = 0
        var offersClaimed = 0
        
        _ = self.offers.map({
            if $0.claim.claimStatus == "" {
                
                offersAvailable += 1
            } else if $0.claim.claimStatus == "claimed" {
                
                offersClaimed += 1
            }
        })
        
        self.availableOffersLabel.text = String(describing: offersAvailable)
        self.redeemedOffersLabel.text = String(describing: offersClaimed)
        self.summaryLabel.text = "$"
    }
    
    private func filterOffers(filterBy: Int) {
        
        var tempArray: [DataOfferObject] = []
        _ = self.offers.map({
            
            if filterBy == 0 && $0.claim.claimStatus == "" {
                
                tempArray.append($0)
            } else if filterBy == 1 && $0.claim.claimStatus == "claimed" {
                
                tempArray.append($0)
            }
        })
        
        self.filteredOffers = tempArray
    }
    
    func filterCollectionView(gesture: UITapGestureRecognizer) {
        
        func animation(index: Int) {
            
            if index == 0 {
                
                self.selectionIndicatorView.frame = CGRect(x: self.availableDataOffersView.frame.origin.x, y: self.selectionIndicatorView.frame.origin.y, width: self.selectionIndicatorView.frame.width, height: self.selectionIndicatorView.frame.height)
            } else if index == 1 {
                
                self.selectionIndicatorView.frame = CGRect(x: self.redeemedDataOffersView.frame.origin.x, y: self.selectionIndicatorView.frame.origin.y, width: self.selectionIndicatorView.frame.width, height: self.selectionIndicatorView.frame.height)
            } else {
                
                self.selectionIndicatorView.frame = CGRect(x: self.summaryDataOffersView.frame.origin.x, y: self.selectionIndicatorView.frame.origin.y, width: self.selectionIndicatorView.frame.width, height: self.selectionIndicatorView.frame.height)
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
            completion: { result in

                print(result)
            }
        )
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.navigationController?.hidesBarsOnSwipe = true
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(named: Constants.ImageNames.tealImage), for: .any, barMetrics: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
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
    
    func showOffers(_ dataOffers: [DataOfferObject]) {
        
        self.offers = dataOffers
        self.filterOffers(filterBy: self.filterBy)
        self.countOffers()
        self.collectionView.reloadData()
    }
    
    // MARK: - Collection View functions
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if self.filterBy != 2 {
            
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.offerCell, for: indexPath) as? DataOffersCollectionViewCell {
                
                return cell.setUpCell(
                    cell: cell,
                    dataOffer: filteredOffers[indexPath.row],
                    completion: { [weak self] image in
                        
                        self?.filteredOffers[indexPath.row].image = image
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
        
        if self.filterBy == 2 {
            
            return CGSize(width: self.collectionView.frame.width - 40, height: 180)
        }
        
        return CGSize(width: self.collectionView.frame.width - 40, height: 340)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if self.filterBy == 2 {
            
            return 3
        }
        
        return filteredOffers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath)
        self.performSegue(withIdentifier: Constants.Segue.offerToOfferDetailsSegue, sender: cell)
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
