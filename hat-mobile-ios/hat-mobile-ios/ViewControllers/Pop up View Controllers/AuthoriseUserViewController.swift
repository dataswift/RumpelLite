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

// MARK: Class

/// Authorise view controller, really a blank view controller needed to present the safari view controller
internal class AuthoriseUserViewController: UIViewController, UserCredentialsProtocol, SFSafariViewControllerDelegate {
    
    // MARK: - Variables
    
    /// The func to execute after completing the authorisation
    var completionFunc: ((String?) -> Void)?

    /// The safari view controller that opened to authorise user again
    private var safari: SFSafariViewController?
    
    /// A static let variable pointing to the AuthoriseUserViewController for checking if token is active or not
    private static let authoriseVC: AuthoriseUserViewController = AuthoriseUserViewController()
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
    
        // add notif observer
        NotificationCenter.default.addObserver(
            self, selector: #selector(dismissView),
            name: NSNotification.Name(Constants.NotificationNames.reauthorised),
            object: nil)
    }
    
    convenience init() {
        
        self.init(nibName:nil, bundle:nil)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(dismissView),
            name: NSNotification.Name(Constants.NotificationNames.reauthorised),
            object: nil)
    }
    
    // This extends the superclass.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        // add notif observer
        NotificationCenter.default.addObserver(
            self, selector: #selector(dismissView),
            name: NSNotification.Name(Constants.NotificationNames.reauthorised),
            object: nil)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Dismiss view controller
    
    /**
     Dismisses view controller from view hierarchy
     
     - parameter notif: A Notification object that called this function
     */
    @objc
    private func dismissView(notif: Notification) {
        
        // get the url form the auth callback
        if let url = notif.object as? NSURL {
            
            // first of all, we close the safari vc
            self.safari?.dismissSafari(animated: true, completion: nil)
            
            // authorize with hat
            HATLoginService.loginToHATAuthorization(
                userDomain: userDomain,
                url: url,
                success: { [weak self] token in
            
                    if let weakSelf = self {
                        
                        KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: token!)
                        KeychainHelper.setKeychainValue(key: Constants.Keychain.logedIn, value: Constants.Keychain.Values.setTrue)
                        
                        weakSelf.removeViewController()
                        
                        NotificationCenter.default.removeObserver(
                            weakSelf,
                            name: NSNotification.Name(Constants.NotificationNames.reauthorised),
                            object: nil)
                    }
                },
                failed: { (_: AuthenicationError) -> Void in return }
            )
        }
    }
    
    // MARK: - Launch safari
    
    /**
     Launches safari
     */
    func launchSafari() {
        
        KeychainHelper.setKeychainValue(key: Constants.Keychain.logedIn, value: Constants.Keychain.Values.expired)

        self.safari = SFSafariViewController.openInSafari(
            url: Constants.HATEndpoints.hatLoginURL(userDomain: self.userDomain),
            on: self,
            animated: true,
            completion: nil)
        
        self.safari?.delegate = self
    }
    
    // MARK: - Safari Delegate Methods
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        
        KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: "")
        KeychainHelper.setKeychainValue(key: Constants.Keychain.logedIn, value: Constants.Keychain.Values.setFalse)
    }
    
    func checkToken(viewController: UIViewController) {
        
        func success(token: String?) {
            
            if token != "" && token != nil {
                
                KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: token!)
                KeychainHelper.setKeychainValue(key: Constants.Keychain.logedIn, value: Constants.Keychain.Values.setTrue)
            }
        }
        
        func failed() {
            
            KeychainHelper.setKeychainValue(key: Constants.Keychain.logedIn, value: Constants.Keychain.Values.expired)
            
            self.launchSafari()
        }
        
        // reset the stack to avoid allowing back
        let result = KeychainHelper.getKeychainValue(key: Constants.Keychain.logedIn)
        
        if result == "false" || userDomain == "" || userToken == "" {
            
            if let loginViewController = viewController.storyboard?.instantiateViewController(withIdentifier: Constants.Segue.loginViewController) as? LoginViewController {
                
                viewController.navigationController?.pushViewController(loginViewController, animated: false)
            }
        // user logged in, set up view
        } else {
            
            // check if the token has expired
            HATAccountService.checkIfTokenExpired(
                token: userToken,
                expiredCallBack: failed,
                tokenValidCallBack: success,
                errorCallBack: viewController.createClassicOKAlertWith)
        }
    }
    
}
