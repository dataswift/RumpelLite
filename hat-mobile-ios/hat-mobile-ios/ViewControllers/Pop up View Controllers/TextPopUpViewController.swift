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

import UIKit

// MARK: Class

/// The class responsible for the text pop up view controller
internal class TextPopUpViewController: UIViewController {
    
    // MARK: - Variables
    
    /// The text to show on the pop up
    var textToShow: String = ""
    
    /// The type of service offer currently shown
    var typeOfService: String = ""
    
    /// The url to redirect to
    var url: String?
    
    /// The voucher to show to user
    var voucher: [String]?
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for controlling the UILabel in order to show the text
    @IBOutlet private weak var textLabel: UILabel!
    
    /// An IBOutlet for controlling the UIButton in order to launch safari
    @IBOutlet private weak var actionButton: UIButton!
    
    // MARK: - IBActions
    
    /**
     Executed when the action button has been tapped. Uses clipboard to copy the text and launch safari
     
     - parameter sender: The object that called this method
     */
    @IBAction func actionButtonAction(_ sender: Any) {
        
        UIPasteboard.general.string = textToShow
        
        if typeOfService == "Service" {
            
            if let url = URL(string: textToShow) {
                
                UIApplication.shared.openURL(url)
            }
        } else if typeOfService == "Voucher" {
            
            if let unwrappedURL = url {
                
                if let tempURL = URL(string: unwrappedURL) {
                    
                    UIApplication.shared.openURL(tempURL)
                }
            }
        }
    }
    
    /**
     Executed when the cancel button has been tapped
     
     - parameter sender: The object that called this method
     */
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        // Animate the view and at the end remove it from the superview
        AnimationHelper.animateView(
            self.view,
            duration: 0.2,
            animations: {[weak self]() -> Void in
                
                if self != nil {
                    
                    self!.view.frame = CGRect(x: self!.view.frame.origin.x, y: self!.view.frame.height, width: self!.view.frame.width, height: self!.view.frame.height)
                }
            },
            completion: {[weak self] (_: Bool) -> Void in
                
                self?.removeViewController()
                NotificationCenter.default.post(name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo), object: nil)
            }
        )
    }
    
    // MARK: - View controller methods

    override func viewDidLoad() {
        
        super.viewDidLoad()

        self.textLabel.text = textToShow
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Init view
    
    /**
     Inits a TextPopUpViewController for immediate use
     
     - parameter stringToShow: The string to show to the pop up
     - parameter storyBoard: The storyboard to init the view from
     
     - returns: An optional instance of TextPopUpViewController ready to present from a view controller
     */
    class func customInit(stringToShow: String, isButtonHidden: Bool, from storyBoard: UIStoryboard) -> TextPopUpViewController? {
        
        let textPopUpViewController = storyBoard.instantiateViewController(withIdentifier: "textPopUpViewController") as? TextPopUpViewController
        textPopUpViewController?.textToShow = stringToShow
        textPopUpViewController?.view.alpha = 0.7
        textPopUpViewController?.actionButton.isHidden = isButtonHidden
        
        return textPopUpViewController
    }
    
    // MARK: - Change action button title
    
    /**
     Changes the title's button
     
     - parameter title: The text to set as title in the button
     */
    func changeButtonTitle(_ title: String) {
        
        self.actionButton.setTitle(title, for: .normal)
        self.actionButton.addBorderToButton(width: 1, color: .white)
    }

}
