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

internal class DataOffersSummaryCollectionViewCell: UICollectionViewCell {
    
    private struct RewardTypes {
        
        static let voucher: String = "Voucher"
        static let service: String = "Service"
        static let cash: String = "Cash"
    }
    
    private struct OffersCount {
        
        var pending: Int = 0
        var completed: Int = 0
        var redeemed: Int = 0
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var offerTypeImage: UIImageView!
    
    @IBOutlet private weak var statsView: UIView!
    
    @IBOutlet private weak var summaryOfferTitleLabel: UILabel!
    @IBOutlet private weak var summaryOfferSubtitleLabel: UILabel!
    @IBOutlet private weak var claimedOffersLabel: UILabel!
    @IBOutlet private weak var pendingOffersLabel: UILabel!
    
    // MARK: - Set up cell
    
    /**
     Sets up the cell to show the data we need
     
     - parameter cell: The cell to set up
     - parameter dataOffer: The data to set up the cell from
     
     - returns: An UICollectionViewCell already been set up
     */
    func setUpCell(cell: DataOffersSummaryCollectionViewCell, index: Int, dataOffers: [DataOfferObject]) -> UICollectionViewCell {
        
        if index == 0 {
            
            let vouchers = dataOffers.filter({
                
                $0.reward.rewardType == RewardTypes.voucher && $0.claim.claimStatus != ""
            })
            self.updateVoucherStats(cell: cell, vouchers: vouchers)
        } else if index == 1 {
            
            let cash = dataOffers.filter({
                
                $0.reward.rewardType == RewardTypes.cash && $0.claim.claimStatus != ""
            })
            self.updateCashStats(cell: cell, cash: cash)
        } else if index == 2 {
            
            let services = dataOffers.filter({
                
                $0.reward.rewardType == RewardTypes.service && $0.claim.claimStatus != ""
            })
            self.updateServiceStats(cell: cell, services: services)
        }
        
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(colorLiteralRed: 231 / 255, green: 231 / 255, blue: 231 / 255, alpha: 1.0).cgColor
        cell.statsView.addLine(view: cell.statsView, xPoint: cell.bounds.midX - 20, yPoint: 0, lineName: Constants.UIViewLayerNames.line)
        
        return cell
    }
    
    private func updateVoucherStats(cell: DataOffersSummaryCollectionViewCell, vouchers: [DataOfferObject]) {
        
        let offersCount = self.countOffers(offers: vouchers)
        
        cell.summaryOfferTitleLabel.text = String(describing: offersCount.redeemed)
        cell.summaryOfferSubtitleLabel.text = "Vouchers redeemed"
        cell.claimedOffersLabel.text = String(describing: offersCount.completed)
        cell.pendingOffersLabel.text = String(describing: offersCount.pending)
        cell.offerTypeImage.image = UIImage(named: Constants.ImageNames.voucherOffersImage)
    }
    
    private func updateCashStats(cell: DataOffersSummaryCollectionViewCell, cash: [DataOfferObject]) {
        
        let offersCount = self.countOffers(offers: cash)
        
        let totalCredit = self.countTotalCreditFromCashOffers(offers: cash)
        let formattedNumber = FormatterHelper.formatNumber(number: NSNumber(value: totalCredit))
        cell.summaryOfferTitleLabel.text = "£ " + formattedNumber!
        cell.summaryOfferSubtitleLabel.text = "Cash earned"
        cell.claimedOffersLabel.text = String(describing: offersCount.completed)
        cell.pendingOffersLabel.text = String(describing: offersCount.pending)
        cell.offerTypeImage.image = UIImage(named: Constants.ImageNames.cashOffersImage)
    }
    
    private func updateServiceStats(cell: DataOffersSummaryCollectionViewCell, services: [DataOfferObject]) {
        
        let offersCount = self.countOffers(offers: services)
        
        cell.summaryOfferTitleLabel.text = String(describing: offersCount.redeemed)
        cell.summaryOfferSubtitleLabel.text = "Services unlocked"
        cell.claimedOffersLabel.text = String(describing: offersCount.completed)
        cell.pendingOffersLabel.text = String(describing: offersCount.pending)
        cell.offerTypeImage.image = UIImage(named: Constants.ImageNames.serviceOffersImage)
    }
    
    private func countTotalCreditFromCashOffers(offers: [DataOfferObject]) -> Int {
        
        var totalCredits: Int = 0
        
        for offer in offers {
            
            totalCredits += (offer.reward.valueInt)!
        }
        
        return totalCredits / 100
    }
    
    private func countOffers(offers: [DataOfferObject]) -> OffersCount {
        
        var offersCount = OffersCount()
        
        for offer in offers {
            
            if offer.claim.claimStatus == "claimed" {
                
                offersCount.pending += 1
            } else if offer.claim.claimStatus == "completed" {
                
                offersCount.completed += 1
            } else if offer.claim.claimStatus == "redeemed" {
                
                offersCount.redeemed += 1
            }
        }
        
        return offersCount
    }
    
}
