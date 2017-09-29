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

import Haneke
import HatForIOS

// MARK: Class

/// The collection view cell class for the photo viewer
internal class PhotosCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// The cell's imageView
    @IBOutlet private weak var image: UIImageView!
    
    /// The ring progress bar of the image curently downloading
    @IBOutlet private weak var ringProgressView: RingProgressCircle!
    
    // MARK: - Calculate Cell Size
    
    /**
     Calculates the size of the cell based on the width of the collectionView
     
     - parameter collectionViewWidth: The collectionView width
     
     - returns: The CGSize of the cell according to the calculations
     */
    class func calculateCellSize(collectionViewWidth: CGFloat) -> CGSize {
        
        let approxWidth = CGFloat(100.0)
        let frameWidth = collectionViewWidth
        let width = CGFloat(frameWidth / CGFloat(Int(frameWidth / approxWidth))) - 5
        
        return CGSize(width: width, height: width)
    }
    
    // MARK: - Set up Cell
    
    /**
     Sets up the cell according to the FileUploadObject data
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     - parameter files: An array of FileUploadObject objects to download
     - parameter indexPath: The indexPath of the cell to set up
     - parameter completion: A competion handler to execute after the cell has been completely set up. Returns the downloaded image
     
     - returns: Returns an already set up cell
     */
    func setUpCell(userDomain: String, userToken: String, files: [FileUploadObject], indexPath: IndexPath, completion: @escaping (UIImage) -> Void, errorCallBack: @escaping () -> Void) -> UICollectionViewCell {
        
        let imageURL: String = Constants.HATEndpoints.fileInfoURL(
            fileID: files[indexPath.row].fileID,
            userDomain: userDomain)

        if files[indexPath.row].image != nil && (files[indexPath.row].image != UIImage(named: Constants.ImageNames.placeholderImage) && files[indexPath.row].image != UIImage(named: Constants.ImageNames.imageDeleted)) {
            
            self.image.image = files[indexPath.row].image
            
            if self.image.image != nil {
                
                completion(self.image.image!)
            }
        } else if URL(string: imageURL) != nil {
            
            self.initRingProgressView()
            
            self.downloadImageFrom(
                imageURL: imageURL,
                userToken: userToken,
                completion: completion,
                errorCallBack: { error in
                    
                    if error.localizedDescription == "not found" || error.localizedDescription == "forbidden" {
                        
                        errorCallBack()
                    }
                }
            )
        } else if self.ringProgressView.isHidden {
            
            self.image.image = files[indexPath.row].image
            
            if self.image.image != nil {
                
                completion(self.image.image!)
            }
        }
        
        return self
    }
    
    // MARK: - Init ringProgressView
    
    /**
     Inits the ringProgressView to default values
     */
    private func initRingProgressView() {
        
        self.ringProgressView.isHidden = false
        self.ringProgressView?.ringRadius = 15
        self.ringProgressView?.animationDuration = 0
        self.ringProgressView?.ringLineWidth = 4
        self.ringProgressView?.ringColor = .white
        self.ringProgressView.animationDuration = 0.2
    }
    
    // MARK: - Download Image
    
    /**
     Downloads the image from the specified URL
     
     - parameter imageURL: The url to download the image from
     - parameter userToken: The user token
     - parameter completion: A function to execute on completion returning the UIImage
     */
    private func downloadImageFrom(imageURL: String, userToken: String, completion: @escaping (UIImage) -> Void, errorCallBack: ((Error) -> Void)? = nil) {
        
        if let url = URL(string: imageURL) {
            
            self.image.hnk_setImage(
                from: url,
                placeholder: UIImage(named: Constants.ImageNames.placeholderImage),
                headers: ["x-auth-token": userToken],
                success: { [weak self] image in
                
                    if let weakSelf = self {
                        
                        weakSelf.ringProgressView.isHidden = true
                        
                        if image != nil {
                            
                            DispatchQueue.main.async {
                                
                                weakSelf.setImageInUIImageView(image: image!)
                                completion(image!)
                            }
                        }
                    }
                },
                failure: { [weak self] error in
                
                    if let weakSelf = self {
                        
                        weakSelf.ringProgressView.isHidden = true
                        weakSelf.setImageInUIImageView(image: UIImage(named: Constants.ImageNames.imageDeleted)!)
                        if error != nil {
                            
                            CrashLoggerHelper.customErrorLog(message: "", error: error!)
                        }
                        
                        errorCallBack?(error!)
                    }
                },
                update: { [weak self] completionProgress in
                    
                    let completion = CGFloat(completionProgress)

                    if let weakSelf = self {
                        
                        weakSelf.ringProgressView.updateCircle(
                            end: completion,
                            animate: Float(weakSelf.ringProgressView.endPoint),
                            removePreviousLayer: false)
                    }
                }
            )
        }
    }
    
    // MARK: - Crop Image
    
    /**
     Crops image in imageview to fit in the imageview frame
     */
    func cropImage() {
        
        self.image.cropImage(width: self.image.frame.size.width, height: self.image.frame.size.height)
    }
    
    // MAR: - Set image in UIImageView
    
    /**
     <#Function Details#>
     
     - parameter <#Parameter#>: <#Parameter description#>
     */
    func setImageInUIImageView(image: UIImage) {
        
        self.image.image = image
    }
}
