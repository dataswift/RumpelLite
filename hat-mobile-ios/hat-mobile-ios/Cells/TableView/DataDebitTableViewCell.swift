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
    
    @IBOutlet private weak var dataDebitImage: UIImageView!
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var dateLabel: UILabel!
    
    // MARK: - Auto generated method

    override func awakeFromNib() {
        
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: - Set up cell
    
    func setUpCell(cell: DataDebitTableViewCell, dataDebit: DataDebitObject) -> DataDebitTableViewCell {
        
        cell.titleLabel.text = dataDebit.name
        cell.subTitleLabel.text = "Kind: \(dataDebit.kind)"
        cell.dateLabel.text = "Expires: " + String(describing: FormatterHelper.formatDateStringToUsersDefinedDate(
            date: dataDebit.endDate!,
            dateStyle: .short,
            timeStyle: .none)
        )
        
        return cell
    }

}
