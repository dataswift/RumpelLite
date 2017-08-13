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
    
    var itemIndex: Int = 0
    private var imageName: String = ""
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var cancelButton: UIButton!
    
    // MARK: - IBActions
    
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

        if itemIndex == 0 {
            
            self.imageView.image = UIImage(named: Constants.ImageNames.imagePopUp1)
        } else if itemIndex == 1 {
            
            self.imageView.image = UIImage(named: Constants.ImageNames.imagePopUp2)
        } else if itemIndex == 2 {
            
            self.imageView.image = UIImage(named: Constants.ImageNames.imagePopUp3)
        } else if itemIndex == 3 {
            
            self.imageView.image = UIImage(named: Constants.ImageNames.imagePopUp4)
        }
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    func setUpViewController(imageName: String) {
        
        self.imageView.image = UIImage(named: imageName)
    }

}
