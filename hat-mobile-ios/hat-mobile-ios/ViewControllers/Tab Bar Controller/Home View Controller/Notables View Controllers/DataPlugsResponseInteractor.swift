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
import SafariServices

internal class DataPlugsResponseInteractor: NSObject, UserCredentialsProtocol {
    
    /// A reference to safari view controller in order to show or hide it
    private var safariVC: SFSafariViewController?
    
    /// Data Plug name
    private var name: String = ""
    
    private var alertMessage: String = ""
    
    override init() {
        
        name = ""
        alertMessage = ""
    }
    
    init(forPlug: String) {
        
        name = forPlug
        alertMessage = "You have to enable \(name.capitalized) data plug before sharing on \(name.capitalized), do you want to enable now?"
    }
    
    // MARK: - Claim offer
    
    /**
     Claims offer for data plug
     */
    class func claimOffer(viewController: UIViewController, failedCompletion: @escaping () -> Void) {
        
        func failCallback(error: DataPlugError) {
            
            switch error {
            case .offerClaimed:
                
                break
            default:
                
                viewController.createClassicOKAlertWith(
                    alertMessage: "There was a problem enabling offer. Please try again later",
                    alertTitle: "Error enabling offer",
                    okTitle: "OK",
                    proceedCompletion: {
                    
                        failedCompletion()
                    }
                )
            }
        }
        
        func success(appToken: String, renewedUserToken: String?) {
            
            HATDataPlugsService.ensureOfferDataDebitEnabled(
                offerID: Constants.DataPlug.offerID,
                succesfulCallBack: { _ in },
                failCallBack: failCallback)(appToken)
        }
        
        HATService.getApplicationTokenFor(
            serviceName: Constants.ApplicationToken.Marketsquare.name,
            userDomain: userDomain,
            token: userToken,
            resource: Constants.ApplicationToken.Marketsquare.source,
            succesfulCallBack: success,
            failCallBack: {(error) in
                
                viewController.createClassicOKAlertWith(
                    alertMessage: "There was a problem enabling offer. Please try again later",
                    alertTitle: "Error enabling offer",
                    okTitle: "OK",
                    proceedCompletion: {})
                CrashLoggerHelper.JSONParsingErrorLogWithoutAlert(error: error)
            }
        )
    }
    
    func turnButtonOn(_ button: UIButton) {
        
        button.alpha = 0.4
    }
    
    func turnButtonOff(_ button: UIButton) {
        
        button.alpha = 0.4
    }

    func dataPlugTokenReceived(button: UIButton, publishButton: UIButton, viewController: ShareOptionsViewController, token: String, renewedUserToken: String?, isPlugEnabledResult: @escaping (Bool) -> Void) {
        
        var fakeInout = ""
        // refresh user token
        KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
        
        func successfulCallback(isActive: Bool) {
            
            if isActive {
                
                PresenterOfShareOptionsViewController.changePublishButtonTo(
                    title: "Save",
                    userEnabled: true,
                    publishButton: publishButton,
                    previousTitle: &fakeInout)
                isPlugEnabledResult(true)
            } else {
                
                failedCallback()
            }
        }
        
        func failedCallback() {
            
            func noAction() {
                
                // if button was selected deselect it and remove the button from the array
                if button.alpha == 1 {
                    
                    turnButtonOff(button)
                } else {
                    
                    turnButtonOn(button)
                }
                
                PresenterOfShareOptionsViewController.changePublishButtonTo(
                    title: "Save",
                    userEnabled: true,
                    publishButton: publishButton,
                    previousTitle: &fakeInout)
                isPlugEnabledResult(false)
            }
            
            func yesAction() {
                
                func successfullCallBack(dataPlugs: [HATDataPlugObject], renewedUserToken: String?) {
                    
                    for i in 0 ... dataPlugs.count - 1 where dataPlugs[i].plug.name == self.name {
                        
                        self.safariVC = SFSafariViewController(url: URL(string: Constants.DataPlug.facebookDataPlugServiceURL(userDomain: viewController.userDomain, socialServiceURL: dataPlugs[i].plug.url))!)
                        PresenterOfShareOptionsViewController.changePublishButtonTo(
                            title: "Save",
                            userEnabled: true,
                            publishButton: publishButton,
                            previousTitle: &fakeInout)
                        viewController.present(self.safariVC!, animated: true, completion: nil)
                        DataPlugsResponseInteractor.claimOffer(viewController: viewController, failedCompletion: {})
                        
                        isPlugEnabledResult(true)
                    }
                    
                    KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
                }
                
                HATDataPlugsService.getAvailableDataPlugs(
                    succesfulCallBack: successfullCallBack,
                    failCallBack: {(error) in
                    
                        isPlugEnabledResult(false)
                        CrashLoggerHelper.dataPlugErrorLog(error: error)
                    }
                )
            }
            
            viewController.createClassicAlertWith(
                alertMessage: alertMessage,
                alertTitle: "Data plug not enabled",
                cancelTitle: "No",
                proceedTitle: "Yes",
                proceedCompletion: yesAction,
                cancelCompletion: noAction)
        }
        
        self.checkPlug(
            token: token,
            successful: successfulCallback,
            failed: { _ in failedCallback() })
    }
    
    private func checkPlug(token: String, successful: @escaping (Bool) -> Void, failed: @escaping (DataPlugError) -> Void) {
        
        if name == "facebook" {
            
            HATFacebookService.isFacebookDataPlugActive(
                appToken: token,
                successful: successful,
                failed: failed)
        } else {
            
            HATTwitterService.isTwitterDataPlugActive(
                appToken: token,
                successful: successful,
                failed: failed)
        }
    }
    
    func dismissSafari(publishButton: UIButton) {
        
        // if safari view controller not nil, hide it
        if safariVC != nil {
            
            safariVC?.dismiss(animated: true, completion: nil)
            publishButton.setTitle("Save", for: .normal)
            publishButton.isUserInteractionEnabled = true
        }
    }
}
