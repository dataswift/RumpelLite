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

internal class ImageSlidePopUpViewController: UIViewController {
    
    // MARK: - Variables
    
    /// An index to pick up the correct image, coresponds to page index of a page view controller
    var itemIndex: Int = -1
    /// The name of the image to show in the imageView
    private var imageName: String = ""
    
    // MARK: - IBOutlets
    
    /// An IBOutlet to handle the imageView
    @IBOutlet private weak var imageView: UIImageView!
    /// An IBOutlet to handle the cancel UIButton
    @IBOutlet private weak var cancelButton: UIButton!
    
    // MARK: - IBActions
    
    /**
     Executed when the cancel button has been tapped, sends a notification to close this view
     
     - parameter sender: The object that called this method
     */
    @IBAction func cancelButtonAction(_ sender: Any) {
        
        NotificationCenter.default.post(
            name: NSNotification.Name(Constants.NotificationNames.imagePopUp),
            object: nil)
    }
    
    // MARK: - Auto-generated methods

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.view.layer.cornerRadius = 15
        self.imageView.layer.cornerRadius = 15
        
        self.chooseImageBasedOn(index: self.itemIndex)
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Set Up View Controller
    
    /**
     Sets up pop up view controller with the specific image
     
     - parameter imageName: The name of the image to show in the pop up
     */
    func setUpViewController(imageName: String) {
        
        self.imageView.image = UIImage(named: imageName)
    }
    
    // MARK: - Choose Image
    
    /**
     Sets up pop up view controller based the index, page number, of the page view controller
     
     - parameter index: The index of the page in page controller
     */
    private func chooseImageBasedOn(index: Int) {
        
        if index == 0 {
            
            self.imageView.image = UIImage(named: Constants.ImageNames.imagePopUp1)
        } else if index == 1 {
            
            self.imageView.image = UIImage(named: Constants.ImageNames.imagePopUp2)
        } else if index == 2 {
            
            self.imageView.image = UIImage(named: Constants.ImageNames.imagePopUp3)
        } else if index == 3 {
            
            self.imageView.image = UIImage(named: Constants.ImageNames.imagePopUp4)
        }
    }

}
