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

internal class GoDeepCollectionViewCell: UICollectionViewCell {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the appImageView of the app
    @IBOutlet private weak var appImageView: UIImageView!
    
    /// An IBOutlet for handling the app name
    @IBOutlet private weak var appName: UILabel!
    /// An IBOutlet for handling the app description
    @IBOutlet private weak var subTitle: UILabel!
    
    // MARK: - Set up cell
    
    /**
     Sets up the cell according to our needs and then it returns it back
     
     - parameter cell: The cell to set up
     - parameter app: The app object, the model, we need to set up the cell
     - parameter indexPath: The indexPath of the cell, used for the background color
     
     - returns: The set up cell
     */
    func setUpCell(_ cell: GoDeepCollectionViewCell, app: GoDeepObject, indexPath: IndexPath) -> UICollectionViewCell {
        
        cell.appName.text = app.appName
        cell.appImageView.image = app.appImage
        cell.subTitle.text = app.appDescription
        
        let orientation = UIInterfaceOrientation(rawValue: UIDevice.current.orientation.rawValue)!
        cell.backgroundColor = cell.backgroundColorOfCellForIndexPath(indexPath, in: orientation)
        
        return cell
    }
    
    // MARK: - Decide background color
    
    /**
     Decides the colof of the cell based on the index path and the device orientation
     
     - parameter indexPath: The index path of the cell
     - parameter orientation: The device current orientation
     
     - returns: The color of the cell based on the index path and the device orientation
     */
    private func backgroundColorOfCellForIndexPath(_ indexPath: IndexPath, in orientation: UIInterfaceOrientation) -> UIColor {
        
        let model = UIDevice.current.model
        if model == "iPhone" {
            
            if orientation.isPortrait {
                
                // create this zebra like color based on the index of the cell
                if (indexPath.row % 4 == 0) || (indexPath.row % 3 == 0) {
                    
                    return .rumpelVeryLightGray
                }
            } else {
                
                // create this zebra like color based on the index of the cell
                if indexPath.row % 2 == 0 {
                    
                    return .rumpelVeryLightGray
                }
            }
            
            return .white
        } else {
            
            if orientation.isPortrait {
                
                // create this zebra like color based on the index of the cell
                if indexPath.row % 5 == 0 || indexPath.row % 5 == 2 {
                    
                    return .rumpelVeryLightGray
                }
            } else {
                
                // create this zebra like color based on the index of the cell
                if indexPath.row % 7 == 0 || indexPath.row % 7 == 2 || indexPath.row % 7 == 4 {
                    
                    return .rumpelVeryLightGray
                }
            }
            
            return .white
        }
    }
    
}
