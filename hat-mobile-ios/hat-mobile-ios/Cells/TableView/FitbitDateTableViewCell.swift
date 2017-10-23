//
//  FitbitDateTableViewCell.swift
//  hat-mobile-ios
//
//  Created by Marios-Andreas Tsekis on 20/10/17.
//  Copyright © 2017 HATDeX. All rights reserved.
//

import UIKit

// MARK: Class

internal class FitbitDateTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlet

    @IBOutlet private weak var dateLabel: UILabel!
    
    // MARK: - Auto generated methods
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Set date
    
    func setDateInLabel(date: String) {
        
        self.dateLabel.text = date
    }

}
