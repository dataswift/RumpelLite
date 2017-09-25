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

internal class DataOfferDetailsViewController: UIViewController, UserCredentialsProtocol {
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the textField UITextView
    @IBOutlet private weak var textField: UITextView!
    /// An IBOutlet for handling the dataRequirmentTextView UITextView
    @IBOutlet private weak var dataRequirmentTextView: UITextView!
    
    /// An IBOutlet for handling the piiExplainedLabel UILabel
    @IBOutlet private weak var piiExplainedLabel: UILabel!
    /// An IBOutlet for handling the offerDurationLabel UILabel
    @IBOutlet private weak var offerDurationLabel: UILabel!
    /// An IBOutlet for handling the title label UILabel
    @IBOutlet private weak var titleLabel: UILabel!
    /// An IBOutlet for handling the detailsLabel UILabel
    @IBOutlet private weak var detailsLabel: UILabel!
    /// An IBOutlet for handling the offersRemainingLabel UILabel
    @IBOutlet private weak var offersRemainingLabel: UILabel!
    /// An IBOutlet for handling the piiEnabledLabel UILabel
    @IBOutlet private weak var ppiEnabledLabel: UILabel!
    
    /// An IBOutlet for handling the imageView
    @IBOutlet private weak var imageView: UIImageView!

    /// An IBOutlet for handling the stackView
    @IBOutlet private weak var stackView: UIStackView!
    
    /// An IBOutlet for handling the infoView UIView
    @IBOutlet private weak var infoView: UIView!
    
    /// An IBOutlet for handling the acceptOfferButton UIButton
    @IBOutlet private weak var acceptOfferButton: UIButton!
    
    // MARK: - Variables
    
    /// The offer received from DataOffersViewController
    var receivedOffer: DataOfferObject?
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    /// A view to show that app is loading, fetching data plugs
    private var loadingView: UIView = UIView()
    
    // MARK: - Claim offer
    
    /**
     Claims the offer the user's currently reading
     
     - parameter appToken: The app token needed to claim the offer
     */
    private func claimOffer(appToken: String) {
        
        func success(claimResult: String, renewedUserToken: String?) {
            
            func alertCompletion() {
                
                self.darkView?.removeFromSuperview()
                self.loadingView.removeFromSuperview()
                
                self.checkOfferStatus(status: claimResult)
                
                if receivedOffer?.reward.rewardType == "Cash" {
                    
                    self.navigationController?.popViewController(animated: true)
                } else if receivedOffer?.reward.rewardType == "Voucher" && (claimResult == "completed" || claimResult == "redeemed") {
                    
                    if let code = self.receivedOffer?.reward.codes?[0] {
                        
                        self.showPopUpWindow(
                            text: code,
                            buttonTitle: "Copy and open in Safari")
                    }
                }
            }
            
            self.acceptOfferButton.layer.backgroundColor = UIColor.clear.cgColor
            self.acceptOfferButton.setTitle("Offer has been accepted", for: .normal)
            self.acceptOfferButton.isEnabled = false
            self.acceptOfferButton.alpha = 0.8
            
            self.createClassicOKAlertWith(
                alertMessage: "You can view your data debits in your settings",
                alertTitle: "Offer has been claimed!",
                okTitle: "OK",
                proceedCompletion: alertCompletion)
        }
        
        func failed(error: DataPlugError) {
            
            self.darkView?.removeFromSuperview()
            self.loadingView.removeFromSuperview()
            
            CrashLoggerHelper.dataPlugErrorLog(error: error)
        }
        
        HATDataOffersService.claimOffer(
            applicationToken: appToken,
            offerID: (receivedOffer?.dataOfferID)!,
            succesfulCallBack: success,
            failCallBack: failed)
    }
    
    // MARK: - IBActions
    
    /**
     Accepts offer
     
     - parameter sender: The object that calls this method
     */
    @IBAction func acceptOfferAction(_ sender: Any) {
        
        let remaining = (receivedOffer?.requiredMaxUsers)! - (receivedOffer?.usersClaimedOffer)!
        if remaining > 0 && self.receivedOffer?.claim.claimStatus == "" {
            
            func gotApplicationToken(appToken: String, newUserToken: String?) {
                
                self.claimOffer(appToken: appToken)
            }
            
            func failedGettingAppToken(error: JSONParsingError) {
                
                self.darkView?.removeFromSuperview()
                self.loadingView.removeFromSuperview()
                
                CrashLoggerHelper.JSONParsingErrorLog(error: error)
            }
            
            self.addBlurToView()
            
            // create loading pop up screen
            self.loadingView = UIView.createLoadingView(
                with: CGRect(x: self.view.frame.midX - 70, y: self.view.bounds.midY - 15, width: 140, height: 30),
                color: .teal,
                cornerRadius: 15,
                in: self.view,
                with: "Accepting offer...",
                textColor: .white,
                font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
            
            HATService.getApplicationTokenFor(
                serviceName: Constants.ApplicationToken.DataBuyer.name,
                userDomain: self.userDomain,
                token: self.userToken,
                resource: Constants.ApplicationToken.DataBuyer.source,
                succesfulCallBack: gotApplicationToken,
                failCallBack: failedGettingAppToken)
        } else if remaining > 0 {
            
            self.showPopUpWindow()
        } else {
            
            self.createClassicOKAlertWith(
                alertMessage: "There are no remaining spots for this offer",
                alertTitle: "Offer reched maximum allowed user number",
                okTitle: "OK",
                proceedCompletion: {})
        }
    }
    
    // MARK: - Check offer status
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     */
    private func checkOfferStatus(status: String) {
        
        if receivedOffer?.reward.rewardType == "Service" {
            
            if status == "completed" || status == "redeemed" {
                
                if let unwrapedVendorURL = self.receivedOffer?.reward.vendorURL {
                    
                    self.showPopUpWindow(
                        text: unwrapedVendorURL,
                        buttonTitle: "Open in Safari")
                }
            } else if status == "accepted" {
                
                self.acceptOfferButton.layer.backgroundColor = UIColor.clear.cgColor
                self.acceptOfferButton.setTitle("Offer has been accepted", for: .normal)
                self.acceptOfferButton.isEnabled = false
                self.acceptOfferButton.alpha = 0.8
            }
        }
        
        if receivedOffer?.reward.rewardType == "Voucher" {
        
            if status == "completed" || status == "redeemed" {
                
                if let code = self.receivedOffer?.reward.codes?[0] {
                    
                    self.showPopUpWindow(
                        text: code,
                        buttonTitle: "Copy and open in Safari")
                }
            } else if status == "accepted" {
                
                self.acceptOfferButton.layer.backgroundColor = UIColor.clear.cgColor
                self.acceptOfferButton.setTitle("Offer has been accepted", for: .normal)
                self.acceptOfferButton.isEnabled = false
                self.acceptOfferButton.alpha = 0.8
            }
        }
    }
    
    // MARK: - Check for received offer
    
    /**
     Checks for PII and sets up the view accordingly
     */
    private func checkForPII() {
        
        self.ppiEnabledLabel.text = "PII NOT REQUESTED"
        self.piiExplainedLabel.text = "NO PERSONALLY IDENTIFIABLE INFORMATION (PII) IS REQUIRED IN THIS OFFER"
    }
    
    /**
     Checks for the offer duration and sets up the view accordingly
     */
    private func checkForOfferDuration() {
        
        if let offer = self.receivedOffer {
            
            if offer.collectsDataFor == 1 {
                
                self.offerDurationLabel.text = "1 DAY DURATION"
            } else {
                
                self.offerDurationLabel.text = "\(String(describing: offer.collectsDataFor)) DAYS DURATION"
            }
        }
    }
    
    /**
     Checks for the offer reward type and sets up the view accordingly
     */
    private func checkForOfferRewardType() {
        
        if self.receivedOffer?.reward.rewardType != "cash" && (self.receivedOffer?.claim.claimStatus == "completed" || self.receivedOffer?.claim.claimStatus == "redeemed") {
            
            self.acceptOfferButton.setTitle("Show reward", for: .normal)
            self.acceptOfferButton.addBorderToButton(width: 1, color: .white)
        } else if self.receivedOffer?.claim.claimStatus != "" {
            
            self.acceptOfferButton.setTitle("Offer has been accepted", for: .normal)
            self.acceptOfferButton.isEnabled = false
            self.acceptOfferButton.alpha = 0.8
        } else {
            
            self.acceptOfferButton.addBorderToButton(width: 1, color: .white)
        }
    }
    
    /**
     Checks for existing received offer and updating view accordingly
     */
    private func checkForReceivedOffer() {
        
        if receivedOffer != nil {
            
            self.title = receivedOffer?.title
            self.titleLabel.text = receivedOffer?.title
            self.detailsLabel.text = receivedOffer?.shortDescription
            self.imageView.image = receivedOffer?.image
            self.textField.text = receivedOffer?.longDescription
            self.offersRemainingLabel.text = "\(String(describing: ((receivedOffer?.requiredMaxUsers)! - (receivedOffer?.usersClaimedOffer)!))) REMAINING"
            self.dataRequirmentTextView.attributedText = self.formatRequiredDataDefinitionText(requiredDataDefinition: (receivedOffer?.requiredDataDefinition)!)
            self.checkForPII()
            self.checkForOfferDuration()
            self.checkForOfferRewardType()
            self.checkOfferStatus(status: receivedOffer!.claim.claimStatus)
        }
    }
    
    // MARK: - Update UI
    
    /**
     Updates the UI adding lines to the infoView and drawing a ticket view
     */
    func updateUI() {
        
        self.stackView.isHidden = false
        
        navigationController?.hidesBarsOnSwipe = false
        
        let view = self.stackView.arrangedSubviews[1]
        view.addLine(
            view: self.infoView,
            xPoint: self.infoView.bounds.width / 3,
            yPoint: 0,
            lineName: Constants.UIViewLayerNames.line)
        view.addLine(
            view: self.infoView,
            xPoint: 2 * self.infoView.bounds.width / 3,
            yPoint: 0,
            lineName: Constants.UIViewLayerNames.line2)
        view.drawTicketView()
    }
    
    // MARK: - View controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.checkForReceivedOffer()
        
        self.stackView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(hidePopUp), name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.updateUI()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        self.updateUI()
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
    
    /**
     Sets up a pop up view controller
     
     - parameter text: The text to put on the main label
     - parameter buttonTitle: The title to put on the button
     */
    private func showPopUpWindow(text: String, buttonTitle: String) {
        
        // set up page controller
        let textPopUpViewController = TextPopUpViewController.customInit(stringToShow: text, isButtonHidden: false, from: self.storyboard!)
        textPopUpViewController?.changeButtonTitle(buttonTitle)
        textPopUpViewController?.typeOfService = (self.receivedOffer?.reward.rewardType)!
        textPopUpViewController?.url = self.receivedOffer?.reward.vendorURL
        textPopUpViewController?.voucher = self.receivedOffer?.reward.codes
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(
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
                weakSelf.addViewController(textPopUpViewController!)
                AnimationHelper.animateView(
                    textPopUpViewController?.view,
                    duration: 0.2,
                    animations: {
                        
                        textPopUpViewController?.view.frame = CGRect(
                            x: weakSelf.view.frame.origin.x + 15,
                            y: weakSelf.view.frame.maxY - 300,
                            width: weakSelf.view.frame.width - 30,
                            height: 400)
                    },
                    completion: { _ in return }
                )
            }
        }
    }
    
    /**
     Based on the type of reward shows the pop up window
     */
    private func showPopUpWindow() {
        
        if receivedOffer?.reward.rewardType == "Service" {
            
            if self.receivedOffer?.claim.claimStatus == "completed" || self.receivedOffer?.claim.claimStatus == "redeemed" {
                
                self.showPopUpWindow(
                    text: (self.receivedOffer?.reward.vendorURL)!,
                    buttonTitle: "Open in Safari")
            }
        } else if receivedOffer?.reward.rewardType == "Voucher" {
            
            if self.receivedOffer?.claim.claimStatus == "completed" || self.receivedOffer?.claim.claimStatus == "redeemed" {
                
                if let codes = self.receivedOffer?.reward.codes {
                    
                    if !codes.isEmpty {
                        
                        self.showPopUpWindow(
                            text: codes[0],
                            buttonTitle: "Copy and open in Safari")
                    }
                }
            }
        }
    }
    
    // MARK: - Add blur View
    
    /**
     Adds blur to the view before presenting the pop up
     */
    private func addBlurToView() {
        
        self.darkView = AnimationHelper.addBlurToView(self.view)
    }
    
    // MARK: - Format Text
    
    /**
     Formatts the requirements to show in a nice way
     
     - parameter requiredDataDefinition: The requred data definition array, holding all the requirements for this offer
     
     - returns: An NSMutableString with the requirements formmated as needed
     */
    private func formatRequiredDataDefinitionText(requiredDataDefinition: [DataOfferRequiredDataDefinitionObject]) -> NSMutableAttributedString {
        
        let textToReturn = NSMutableAttributedString(
            string: "REQUIREMENTS:\n",
            attributes: [NSAttributedStringKey.font: UIFont(name: Constants.FontNames.openSans, size: 13)!])
        
        for requiredData in requiredDataDefinition {
            
            let string = NSMutableAttributedString(
                string: "\(requiredData.source)\n",
                attributes: [NSAttributedStringKey.font: UIFont(name: Constants.FontNames.openSansBold, size: 13)!])
            
            textToReturn.append(string)
            
            for dataSet in requiredData.dataSets {
                
                func reccuringFields(fieldsArray: [DataOfferRequiredDataDefinitionDataSetsFieldsObject], intend: String) -> NSMutableAttributedString {
                    
                    let tempText = NSMutableAttributedString(
                        string: "",
                        attributes: [NSAttributedStringKey.font: UIFont(name: Constants.FontNames.openSans, size: 13)!])
                    
                    for field in fieldsArray {
                        
                        let fieldString = NSMutableAttributedString(
                            string: "\(intend)\(field.name)\n",
                            attributes: [NSAttributedStringKey.font: UIFont(name: Constants.FontNames.openSans, size: 13)!])
                        
                        tempText.append(fieldString)
                        
                        if !field.fields.isEmpty {
                            
                            tempText.append(reccuringFields(fieldsArray: field.fields, intend: "\(intend)\t"))
                        }
                    }
                    
                    return tempText
                }
                
                let dataName = NSMutableAttributedString(
                    string: "\t\(dataSet.name)\n",
                    attributes: [NSAttributedStringKey.font: UIFont(name: Constants.FontNames.openSans, size: 13)!])
                
                textToReturn.append(dataName)
                textToReturn.append(reccuringFields(fieldsArray: dataSet.fields, intend: "\t\t"))
            }
        }
        
        return textToReturn
    }

}
