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

/// the notables table view cell class
internal class NotablesTableViewCell: UITableViewCell, UICollectionViewDataSource, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// an array to hold the social networks that this note is shared on
    private var sharedOn: [String] = []
    
    /// an UIImage to hold the full size image
    var fullSizeImage: UIImage?
    
    /// a delegate to update the value of the cell
    weak var notesDelegate: NotablesViewController?
    
    // MARK: - IBOutlets

    /// An IBOutlet for handling the info of the post
    @IBOutlet private weak var postInfoLabel: UILabel!
    /// An IBOutlet for handling the data of the post
    @IBOutlet private weak var postDataLabel: UILabel!
    /// An IBOutlet for handling the username of the post
    @IBOutlet private weak var usernameLabel: UILabel!
    
    /// An IBOutlet for the attached image of the note, if any
    @IBOutlet private weak var attachedImage: UIImageView!
    /// An IBOutlet for handling the profile image of the post
    @IBOutlet private weak var profileImage: UIImageView!
    
    /// An IBOutlet for showing the download completion of the image
    @IBOutlet private weak var ringProgressBar: RingProgressCircle!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - Setup cell
    
    /**
     Sets up the cell from the note
     
     - parameter cell: The cell to set up
     - parameter note: The data to show on the cell
     - parameter indexPath: The index path of the cell
     
     - returns: NotablesTableViewCell
     */
    func setUpCell(_ cell: NotablesTableViewCell, note: HATNotesV2Object, indexPath: IndexPath) -> NotablesTableViewCell {
        
        let newCell = self.initCellToNil(cell: cell)
        
        self.updateCellUI(newCell: newCell, note: note, indexPath: indexPath)
        
        self.updateCellData(newCell: newCell, note: note, indexPath: indexPath)
        
        // return the cell
        return newCell
    }
    
    /**
     Updates the cell UI
     
     - parameter newCell: The cell to set up
     - parameter note: The model that holds our data
     - parameter indexPath: The index path of the cell
     */
    private func updateCellUI(newCell: NotablesTableViewCell, note: HATNotesV2Object, indexPath: IndexPath) {
        
        guard note.data.photov1 != nil,
            note.data.photov1?.link != nil else {
            
            return
        }
        
        if let url = URL(string: (note.data.photov1?.link!)!) {
            
            self.downloadAttachedImage(
                cell: newCell,
                url: url,
                row: indexPath.row,
                note: note,
                weakSelf: self)
        }
        
        // if the note is shared get the shared on string as well
        if note.data.shared {
            
            newCell.sharedOn = note.data.shared_on.sorted()
            self.sharedOn = newCell.sharedOn
        }
        
        let locationData = note.data.locationv1
        if locationData?.longitude != nil && locationData?.latitude != nil && (locationData?.longitude != 0 && locationData?.latitude != 0 && locationData?.accuracy != 0) {
            
            newCell.sharedOn.append("location")
            self.sharedOn = newCell.sharedOn
        }
    }
    
    /**
     Updates cell data
     
     - parameter newCell: The cell to set up
     - parameter note: The model that holds our data
     - parameter indexPath: The index path of the cell
     */
    private func updateCellData(newCell: NotablesTableViewCell, note: HATNotesV2Object, indexPath: IndexPath) {
        
        // get the author data
        let authorData = note.data.authorv1
        // get the created date
        let createdTime = FormatterHelper.formatStringToDate(string: note.data.created_time)
        
        let date = FormatterHelper.formatDateStringToUsersDefinedDate(
            date: createdTime!,
            dateStyle: .short,
            timeStyle: .short)
        
        // create this zebra like color based on the index of the cell
        if indexPath.row % 2 == 1 {
            
            newCell.contentView.backgroundColor = .rumpelLightGray
        }
        
        let publicUntil: Date?
        if note.data.public_until != nil && note.data.public_until != "" && note.data.public_until != note.data.created_time {
            
            publicUntil = FormatterHelper.formatStringToDate(string: note.data.public_until!)
        } else {
            
            publicUntil = nil
        }
        
        // show the data in the cell's labels
        newCell.postDataLabel.text = note.data.message
        newCell.usernameLabel.text = authorData.phata
        newCell.postInfoLabel.attributedText = self.formatInfoLabel(
            date: date,
            shared: note.data.shared,
            publicUntil: publicUntil)
        
        // flip the view to appear from right to left
        newCell.collectionView.transform = CGAffineTransform(scaleX: -1, y: 1)
    }
    
    // MARK: - Download attached image
    
    /**
     Download the attached image of the note
     
     - parameter cell: The cell to download the image to
     - parameter url: The url to download the image from
     - parameter row: The row of the cell to update when the download fishishes
     - parameter note: The note file to put the data on to update the cell
     - parameter weakSelf: The weakSelf
     */
    func downloadAttachedImage(cell: NotablesTableViewCell, url: URL, row: Int, note: HATNotesV2Object, weakSelf: NotablesTableViewCell) {
        
        cell.attachedImage.image = UIImage(named: Constants.ImageNames.placeholderImage)
        
        self.initRingProgressBar(cell: cell)
        
        cell.attachedImage.hnk_setImage(
            from: url,
            placeholder: UIImage(named: Constants.ImageNames.placeholderImage),
            headers: ["x-auth-token": userToken],
            success: { image in
                
                cell.attachedImage.image = image
                //NotesCachingWrapperHelper.addImageToNote(recordID: note.recordId, link: note.data.photov1!.link!, userToken: weakSelf.userToken, image: weakSelf.attachedImage.image)
                
                cell.ringProgressBar.isHidden = true
                if cell.attachedImage.image != nil {
                    
                    cell.fullSizeImage = cell.attachedImage.image!
                }
                cell.attachedImage.cropImage(
                    width: cell.attachedImage.frame.width,
                    height: cell.attachedImage.frame.height)
                
                cell.notesDelegate?.updateNote(note, at: row)
            },
            failure: { [weak self] _ in
                
                guard let weakSelf = self else {
                    
                    return
                }
                
                weakSelf.ringProgressBar.isHidden = true
            },
            update: { [weak self] progress in
                
                guard let weakSelf = self else {
                    
                    return
                }
                
                let completion = Float(progress)
                weakSelf.ringProgressBar.updateCircle(
                    end: CGFloat(completion),
                    animate: Float(weakSelf.ringProgressBar.endPoint),
                    removePreviousLayer: false)
            }
        )
    }
    
    // MARK: - Init ringProgressView
    
    /**
     Inits the ringProgressView to default values
     
     - parameter cell: The cell to init the ringProgressBar
     */
    private func initRingProgressBar(cell: NotablesTableViewCell) {
        
        cell.ringProgressBar.isHidden = false
        cell.ringProgressBar.ringRadius = 10
        cell.ringProgressBar.ringLineWidth = 4
        cell.ringProgressBar.ringColor = .white
    }
    
    // MARK: - CollectionView datasource methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.sharedOn.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // set up cell from the reuse identifier
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.socialCell, for: indexPath) as? SocialImageCollectionViewCell {
            
            //return the cell
            return cell.setUpCell(self.sharedOn[indexPath.row])
        }
        
        return collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.socialCell, for: indexPath)
    }
    
    // MARK: - Init Cell
    
    /**
     Initialises a cell to the default values
     
     - parameter cell: The cell to init to the default values
     
     - returns: NotablesTableViewCell with default values
     */
    private func initCellToNil(cell: NotablesTableViewCell) -> NotablesTableViewCell {
        
        cell.postDataLabel.text = ""
        cell.usernameLabel.text = ""
        cell.postInfoLabel.text = ""
        
        cell.sharedOn.removeAll()
        self.sharedOn.removeAll()
        
        cell.collectionView.reloadData()
        
        cell.contentView.backgroundColor = .rumpelDarkGray

        return cell
    }
    
    // MARK: - Format Cell
    
    /**
     Formats the info label to date + Private if it's private. Also those two fields have different font color.
     
     - parameter date: The date to add to the string
     - parameter shared: A bool value defining if the note is shared
     - parameter publicUntil: An optional Date value defining the date that this note will turn to private
     
     - returns: An NSAttributesString with 2 different colors
     */
    private func formatInfoLabel(date: String, shared: Bool, publicUntil: Date?) -> NSAttributedString {
        
        // format the info label
        let string = "Posted \(date)"
        var shareString: String = " Private Note"
        
        if shared {
            
            shareString = " Shared"
        }
        
        if let unwrappedDate = publicUntil {
            
            if shared && (Date() > unwrappedDate) {
                
                shareString = " Expired"
            }
        }
        
        let partOne = NSAttributedString(string: string)
        let partTwo = shareString.createTextAttributes(
            foregroundColor: .teal,
            strokeColor: .teal,
            font: UIFont(name: Constants.FontNames.openSans, size: 11)!)
        
        return partOne.combineWith(attributedText: partTwo)
    }
}
