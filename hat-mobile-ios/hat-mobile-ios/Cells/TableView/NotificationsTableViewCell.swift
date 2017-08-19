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

internal class NotificationsTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the descriptionLabel UILabel
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    /// An IBOutlet for handling the dateLabel UILabel
    @IBOutlet private weak var dateLabel: UILabel!
    
    /// An IBOutlet for handling the titleLabel UILabel
    @IBOutlet private weak var titleLabel: UILabel!
    
    // MARK: - Auto-generated methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }

    // MARK: - Set title
    
    /**
     Set a title in the label
     
     - parameter text: The text to show to label
     */
    func setTitleInLabel(_ text: String) {
        
        self.titleLabel.text = text
    }
    
    /**
     Set a description in the label
     
     - parameter text: The text to show to label
     */
    func setDescriptionInLabel(_ text: String) {
        
        self.descriptionLabel.text = text
    }
    
    /**
     Set a date in the label
     
     - parameter text: The text to show to label
     */
    func setDateInLabel(_ text: String) {
        
        self.dateLabel.text = text
    }
}
