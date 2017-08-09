//
//  NotificationsTableViewCell.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 2/8/17.
//  Copyright © 2017 HATDeX. All rights reserved.
//

import UIKit

internal class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet private weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }

    func setTitleInLabel(_ text: String) {
        
        self.titleLabel.text = text
    }
}
