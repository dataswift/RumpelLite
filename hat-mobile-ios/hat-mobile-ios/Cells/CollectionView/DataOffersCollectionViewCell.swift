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

/// A class responsible for handling the Data Offers Collection View cell
internal class DataOffersCollectionViewCell: UICollectionViewCell, UserCredentialsProtocol {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the imageView
    @IBOutlet private weak var imageView: UIImageView!
    
    /// An IBOutlet for handling the title UILabel
    @IBOutlet private weak var titleLabel: UILabel!
    /// An IBOutlet for handling the details UILabel
    @IBOutlet private weak var detailsLabel: UILabel!
    
    /// An IBOutlet for handling the ringProgressBar RingProgressCircle
    @IBOutlet private weak var ringProgressBar: RingProgressCircle!
    
    // MARK: - Set up cell
    
    /**
     Sets up the cell to show the data we need
     
     - parameter cell: The cell to set up
     - parameter dataOffer: The data to set up the cell from
     - parameter completion: An optional function to execute returning the downloaded image
     
     - returns: An UICollectionViewCell already been set up
     */
    func setUpCell(cell: DataOffersCollectionViewCell, dataOffer: DataOfferObject, completion: ((UIImage) -> Void)?) -> UICollectionViewCell {
        
        self.setUpCellUI(cell: cell, dataOffer: dataOffer)

        if dataOffer.image == nil {
            
            self.downloadOfferImage(url: dataOffer.illustrationURL, cell: cell, completion: completion)
        }
        
        return cell
    }
    
    /**
     Updates the cell's UI
     
     - parameter cell: The cell to update the UI
     - parameter dataOffer: The dataOffer object holding the data we need in order to update the cell
     */
    private func setUpCellUI(cell: DataOffersCollectionViewCell, dataOffer: DataOfferObject) {
        
        cell.titleLabel.text = dataOffer.title
        cell.detailsLabel.text = dataOffer.shortDescription
        cell.imageView.image = dataOffer.image
        
        cell.ringProgressBar.ringColor = .white
        cell.ringProgressBar.ringRadius = 45
        cell.ringProgressBar.ringLineWidth = 4
        cell.ringProgressBar.animationDuration = 0.2
        cell.ringProgressBar.isHidden = true
        
        cell.layer.cornerRadius = 5
        cell.layer.borderWidth = 2
        cell.layer.borderColor = UIColor(
            colorLiteralRed: 231 / 255,
            green: 231 / 255,
            blue: 231 / 255,
            alpha: 1.0).cgColor
    }
    
    // MARK: - Update progressBar
    
    /**
     Updates the progress bar according to the completion status
     
     - parameter completion: The download completion status
     */
    private func updateProgressBar(completion: Double) {
        
        ringProgressBar.updateCircle(end: CGFloat(completion), animate: 0.2, removePreviousLayer: true)
    }
    
    // MARK: - Download image
    
    /**
     Downloads the offer image
     
     - parameter url: The url to connect to in order to get the image
     - parameter cell: The cell to download the image to
     - parameter completion: A completion handler to execute after the image download has been completed
     */
    private func downloadOfferImage(url: String, cell: DataOffersCollectionViewCell, completion: ((UIImage) -> Void)?) {
        
        func showDefaultImage() {
            
            cell.ringProgressBar.isHidden = true
            cell.imageView.image = UIImage(named: Constants.ImageNames.placeholderImage)
            completion?(cell.imageView.image!)
        }
        
        if let unwrappedURL = URL(string: url) {
            
            cell.ringProgressBar.isHidden = false
            cell.imageView.downloadedFrom(
                url: unwrappedURL,
                userToken: self.userToken,
                progressUpdater: updateProgressBar,
                completion: {
                    
                    if let image = cell.imageView.image {
                        
                        cell.ringProgressBar.isHidden = true
                        completion?(image)
                    } else {
                        
                        showDefaultImage()
                    }
                }
            )
        } else {
            
            showDefaultImage()
        }
    }
}
