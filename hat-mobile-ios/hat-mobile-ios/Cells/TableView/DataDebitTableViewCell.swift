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

internal class DataDebitTableViewCell: UITableViewCell {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the data debit imageView
    @IBOutlet private weak var dataDebitImage: UIImageView!
    
    /// An IBOutlet for handling the data debit title label
    @IBOutlet private weak var titleLabel: UILabel!
    /// An IBOutlet for handling the data debit description label
    @IBOutlet private weak var subTitleLabel: UILabel!
    /// An IBOutlet for handling the data debit date label
    @IBOutlet private weak var dateLabel: UILabel!
    
    // MARK: - Auto generated method

    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Set up cell
    
    /**
     Sets up the cell according to our needs
     
     - parameter cell: The cell to set up
     - parameter dataDebit: The data debit, the model, to set up the cell from
     
     - returns: A formatted social feed cell of type DataDebitTableViewCell
     */
    func setUpCell(cell: DataDebitTableViewCell, dataDebit: DataDebitObject) -> DataDebitTableViewCell {
        
        cell.titleLabel.text = dataDebit.name
        cell.subTitleLabel.text = "Kind: \(dataDebit.kind)"
        cell.dateLabel.text =
        "Expires: \(String(describing: FormatterHelper.formatDateStringToUsersDefinedDate(date: dataDebit.endDate!, dateStyle: .short, timeStyle: .none)))"
        
        return cell
    }

}
