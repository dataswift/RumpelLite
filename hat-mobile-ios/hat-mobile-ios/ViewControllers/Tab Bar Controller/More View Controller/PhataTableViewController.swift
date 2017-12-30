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

/// A class responsible for the phata UITableViewController of the more tab bar
internal class PhataTableViewController: UITableViewController, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// The sections of the table view
    private let sections: [[String]] = [["PHATA"], ["Social Links"], ["Email Address", "Mobile Number", "Locale"], ["Full Name", "Picture"], ["Emergency Contact"], ["Biodata"]]
    /// The headers of the table view
    private let headers: [String] = ["PHATA", "Social Links", "Contact Info", "Profile", "Emergency Contact", "Biodata"]
    /// The footers of the table view
    private let footers: [String] = ["PHATA stands for Personal HAT Address. Your PHATA page is the URL of your public profile, and you can customise exactly which parts of it you want to display, or keep private.", "", "", "", "", ""]
    
    /// User's profile passed on from previous view controller
    var profile: ProfileObject?
    
    var isProfileDownloaded: Bool = false
    
    /// A static let variable pointing to the AuthoriseUserViewController for checking if token is active or not
    private static let authoriseVC: AuthoriseUserViewController = AuthoriseUserViewController()
    
    var prefferedTitle: String = "PHATA"
    var prefferedInfoMessage: String = "Your PHATA is your public profile. Enable it to use it as a calling card!"
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    private var loadingView: UIView?
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var infoPopUpButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func infoPopUpButtonAction(_ sender: Any) {
        
        self.showInfoViewController(text: prefferedInfoMessage)
        self.infoPopUpButton.isUserInteractionEnabled = false
    }
    
    // MARK: - Update profile responses
    
    /**
     Gets profile from hat and saves it to a local variable
     
     - parameter receivedProfile: The received HATProfileObjectV2 from HAT
     */
    private func getProfile(receivedProfile: [ProfileObject], newToken: String?) {
        
        if !receivedProfile.isEmpty {
            
            self.loadingView?.removeFromSuperview()
            self.tableView.isUserInteractionEnabled = true
            
            self.profile = receivedProfile[0]
            
            self.isProfileDownloaded = true
            
            self.tableView.reloadData()
        }
    }
    
    // MARK: - View Controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.title = self.prefferedTitle
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // check token
        self.addChildViewController(PhataTableViewController.authoriseVC)
        PhataTableViewController.authoriseVC.checkToken(viewController: self)
        
        self.tableView.reloadData()
        
        self.tableView.isUserInteractionEnabled = false
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.tableView?.frame.midX)! - 70, y: (self.tableView?.frame.midY)! - 15, width: 160, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Loading HAT data...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        
        ProfileCachingHelper.getProfile(
            userToken: userToken,
            userDomain: userDomain,
            cacheTypeID: "profile",
            successRespond: getProfile,
            failRespond: { _ in return })
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        
        if self.isProfileDownloaded {
            
            return true
        }
        
        return false
    }

    // MARK: - Table view methods

    override func numberOfSections(in tableView: UITableView) -> Int {

        return self.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return self.sections[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.phataCell, for: indexPath)

        return self.setUpCell(cell, indexPath: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return self.headers[section]
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        
        if section < self.footers.count {
            
            return self.footers[section]
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if self.profile != nil && self.isProfileDownloaded {
            
            if indexPath.section == 0 {
                
                if indexPath.row == 0 {
                    
                    self.performSegue(withIdentifier: Constants.Segue.phataSettingsSegue, sender: self)
                }
            
            } else if indexPath.section == 1 {
                
                self.performSegue(withIdentifier: Constants.Segue.phataToSocialLinksSegue, sender: self)
            } else if indexPath.section == 2 {
                
                if indexPath.row == 0 {
                    
                    self.performSegue(withIdentifier: Constants.Segue.phataToEmailSegue, sender: self)
                } else if indexPath.row == 1 {
                    
                    self.performSegue(withIdentifier: Constants.Segue.phataToPhoneSegue, sender: self)
                } else if indexPath.row == 2 {
                    
                    self.performSegue(withIdentifier: Constants.Segue.phataToAddressSegue, sender: self)
                }
            } else if indexPath.section == 3 {
                
                if indexPath.row == 0 {
                    
                    self.performSegue(withIdentifier: Constants.Segue.phataToNameSegue, sender: self)
                } else if indexPath.row == 1 {
                    
                    self.performSegue(withIdentifier: Constants.Segue.phataToProfilePictureSegue, sender: self)
                }
            } else if indexPath.section == 4 {
                
                self.performSegue(withIdentifier: Constants.Segue.phataToEmergencyContactSegue, sender: self)
            } else if indexPath.section == 5 {
                
                self.performSegue(withIdentifier: Constants.Segue.phataToAboutSegue, sender: self)
            }
        } else {
            
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Set up cell
    
    /**
     Updates and formats the cell accordingly
     
     - parameter cell: The UITableViewCell to update and format
     - parameter indexPath: The indexPath of the cell
     
     - returns: A UITableViewCell cell already updated and formatted accordingly
     */
    private func setUpCell(_ cell: UITableViewCell, indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            cell.textLabel?.text = self.userDomain
            cell.accessoryType = .disclosureIndicator
        } else {
            
            cell.textLabel?.text = self.sections[indexPath.section][indexPath.row]
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
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
        
        let calculatedHeight = textPopUpViewController!.getLabelHeight() + 150
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(
            frame: CGRect(
                x: self.view.frame.origin.x + 15,
                y: self.tableView.frame.maxY,
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
                            y: weakSelf.tableView.frame.maxY - calculatedHeight,
                            width: weakSelf.view.frame.width - 30,
                            height: calculatedHeight)
                    },
                    completion: { _ in return }
                )
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if self.profile != nil && self.isProfileDownloaded {
            
            if segue.destination is NameTableViewController {
                
                weak var destinationVC = segue.destination as? NameTableViewController
                
                if segue.identifier == Constants.Segue.phataToNameSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is ProfileInfoTableViewController {
                
                weak var destinationVC = segue.destination as? ProfileInfoTableViewController
                
                if segue.identifier == Constants.Segue.phataToProfileInfoSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is EmailTableViewController {
                
                weak var destinationVC = segue.destination as? EmailTableViewController
                
                if segue.identifier == Constants.Segue.phataToEmailSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is PhoneTableViewController {
                
                weak var destinationVC = segue.destination as? PhoneTableViewController
                
                if segue.identifier == Constants.Segue.phataToPhoneSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is AboutTableViewController {
                
                weak var destinationVC = segue.destination as? AboutTableViewController
                
                if segue.identifier == Constants.Segue.phataToAboutSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is SocialLinksTableViewController {
                
                weak var destinationVC = segue.destination as? SocialLinksTableViewController
                
                if segue.identifier == Constants.Segue.phataToSocialLinksSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is EmergencyContactTableViewController {
                
                weak var destinationVC = segue.destination as? EmergencyContactTableViewController
                
                if segue.identifier == Constants.Segue.phataToEmergencyContactSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is PhataPictureViewController {
                
                weak var destinationVC = segue.destination as? PhataPictureViewController
                
                if segue.identifier == Constants.Segue.phataToProfilePictureSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is PHATASettingsTableViewController {
                
                weak var destinationVC = segue.destination as? PHATASettingsTableViewController
                
                if segue.identifier == Constants.Segue.phataSettingsSegue {
                    
                    destinationVC?.profile = self.profile
                }
            } else if segue.destination is AddressTableViewController {
                
                weak var destinationVC = segue.destination as? AddressTableViewController
                
                if segue.identifier == Constants.Segue.phataToAddressSegue {
                    
                    destinationVC?.profile = self.profile
                }
            }
        }
    }

}
