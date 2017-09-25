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

internal class PresenterOfShareOptionsViewController: NSObject, UserCredentialsProtocol {

    // MARK: - Create Upload Options Alert
        
    class func createUploadPhotoOptionsAlert(sourceRect: CGRect, sourceView: UIView, viewController: ShareOptionsViewController, photosViewController: PhotosHelperViewController) -> UIAlertController {
        
        let alertController = UIAlertController(title: "Select options", message: "Select from where to upload image", preferredStyle: .actionSheet)
        
        // create alert actions
        let cameraAction = UIAlertAction(title: "Take photo", style: .default, handler: { (_) -> Void in
            
            let picker = photosViewController.presentPicker(sourceType: .camera)
            viewController.present(picker, animated: true, completion: nil)
        })
        
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default, handler: { (_) -> Void in
            
            let picker = photosViewController.presentPicker(sourceType: .photoLibrary)
            viewController.present(picker, animated: true, completion: nil)
        })
        
        let selectFromHATAction = UIAlertAction(title: "Choose from HAT", style: .default, handler: { (_) -> Void in
            
            viewController.performSegue(withIdentifier: "createNoteToHATPhotosSegue", sender: viewController)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addActions(actions: [cameraAction, libraryAction, selectFromHATAction, cancel])
        alertController.addiPadSupport(sourceRect: sourceRect, sourceView: sourceView)
        
        return alertController
    }
    
    // MARK: - Create Share for Duration Options Alert
    
    class func createShareForDurationAlertController(sourceRect: CGRect, sourceView: UIView, viewController: ShareOptionsViewController) -> UIAlertController {
        
        let alertController = UIAlertController(title: "For how long...", message: "Select the duration you want this note to be shared for", preferredStyle: .actionSheet)
        
        // create alert actions
        let oneDayAction = UIAlertAction(title: "1 day", style: .default, handler: { (action) -> Void in
            
            viewController.updateShareOptions(buttonTitle: action.title!, byAdding: .day, value: 1)
        })
        
        let sevenDaysAction = UIAlertAction(title: "7 days", style: .default, handler: { (action) -> Void in
            
            viewController.updateShareOptions(buttonTitle: action.title!, byAdding: .day, value: 7)
        })
        
        let fourteenDaysAction = UIAlertAction(title: "14 days", style: .default, handler: { (action) -> Void in
            
            viewController.updateShareOptions(buttonTitle: action.title!, byAdding: .day, value: 14)
        })
        
        let oneMonthAction = UIAlertAction(title: "1 month", style: .default, handler: { (action) -> Void in
            
            viewController.updateShareOptions(buttonTitle: action.title!, byAdding: .month, value: 1)
        })
        
        let forEverAction = UIAlertAction(title: "Forever", style: .default, handler: { (action) -> Void in
            
            viewController.updateShareOptions(buttonTitle: action.title!, byAdding: nil, value: nil)
        })
        
        let cancelButton = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // add those actions to the alert controller
        let actionsArray = [oneDayAction, sevenDaysAction, fourteenDaysAction, oneMonthAction, forEverAction, cancelButton]
        alertController.addActions(actions: actionsArray)
        alertController.addiPadSupport(sourceRect: sourceRect, sourceView: sourceView)
        
        return alertController
    }
    
    // MARK: - Change Publish button
    
    class func changePublishButtonTo(title: String, userEnabled: Bool, publishButton: UIButton, previousTitle: inout String) {
        
        previousTitle = (publishButton.titleLabel?.text)!
        
        // change button title to saving
        publishButton.setTitle(title, for: .normal)
        publishButton.isUserInteractionEnabled = userEnabled
        
        if !userEnabled {
            
            publishButton.alpha = 0.5
        } else {
            
            publishButton.alpha = 1.0
        }
    }
    
    class func restorePublishButtonToPreviousState(isUserInteractionEnabled: Bool, previousTitle: String, publishButton: UIButton) {
        
        // change publish button back to default state
        publishButton.setTitle(previousTitle, for: .normal)
        publishButton.isUserInteractionEnabled = isUserInteractionEnabled
        
        if isUserInteractionEnabled {
            
            publishButton.alpha = 1
        }
    }
    
    class func checkImage(imageSelected: UIImageView) {
        
        var isPNG = false
        
        if imageSelected.image != nil {
            
            var tempData = UIImageJPEGRepresentation(imageSelected.image!, 1.0)
            if tempData == nil {
                
                tempData = UIImagePNGRepresentation(imageSelected.image!)
                isPNG = true
            }
            
            if tempData != nil {
                
                let data = NSData(data: tempData!)
                let size = Float(Float(Float(data.length) / 1024) / 1024)
                
                if isPNG && size > 1 {
                    
                    imageSelected.image = imageSelected.image!.resized(fileSize: size, maximumSize: 1)!
                } else if !isPNG && size > 3 {
                    
                    imageSelected.image = imageSelected.image!.resized(fileSize: size, maximumSize: 3)!
                }
            }
        }
    }
    
    class func checkForImageAndUpload(imagesToUpload: [UIImage], viewController: ShareOptionsViewController, imageSelected: UIImageView) {
        
        if !imagesToUpload.isEmpty {
            
            PresenterOfShareOptionsViewController.checkImage(imageSelected: imageSelected)
            
            viewController.uploadImage()
        } else {
            
            viewController.postNote()
        }
    }
    
    class func test(viewController: ShareOptionsViewController, receivedNote: HATNotesData, imagesToUpload: [UIImage], isEditingExistingNote: Bool, cachedIsNoteShared: Bool, textViewText: String, publishButton: UIButton, previousPublishButtonTitle: String, imageSelected: UIImageView) {
        
        // if note is shared and users have not selected any social networks to share show alert message
        if receivedNote.data.shared && receivedNote.data.sharedOn == "" {
            
            viewController.createClassicOKAlertWith(
                alertMessage: "Please select at least one shared destination",
                alertTitle: "",
                okTitle: "OK",
                proceedCompletion: {
            
                        PresenterOfShareOptionsViewController.restorePublishButtonToPreviousState(
                        isUserInteractionEnabled: true,
                        previousTitle: previousPublishButtonTitle,
                        publishButton: publishButton)
                }
            )
        }
        
        // not editing note
        if !isEditingExistingNote {
            
            if receivedNote.data.shared && imagesToUpload.isEmpty {
                
                viewController.createClassicAlertWith(
                    alertMessage: "You are about to share your post. \n\nTip: to remove a note from the external site, edit the note and make it private.",
                    alertTitle: "",
                    cancelTitle: "Cancel",
                    proceedTitle: "Share now",
                    proceedCompletion: viewController.postNote,
                    cancelCompletion: {
                        
                        PresenterOfShareOptionsViewController.restorePublishButtonToPreviousState(
                            isUserInteractionEnabled: true,
                            previousTitle: previousPublishButtonTitle,
                            publishButton: publishButton)
                    }
                )
            } else if receivedNote.data.shared {
                
                viewController.createClassicAlertWith(
                    alertMessage: "You are about to share your post. \n\nTip: to remove a note from the external site, edit the note and make it private.",
                    alertTitle: "",
                    cancelTitle: "Cancel",
                    proceedTitle: "Share now",
                    proceedCompletion: {
                
                        PresenterOfShareOptionsViewController.checkForImageAndUpload(
                            imagesToUpload: imagesToUpload,
                            viewController: viewController,
                            imageSelected: imageSelected)
                    },
                    cancelCompletion: {
                    
                        PresenterOfShareOptionsViewController.restorePublishButtonToPreviousState(
                            isUserInteractionEnabled: true,
                            previousTitle: previousPublishButtonTitle,
                            publishButton: publishButton)
                    }
                )
            } else {
                
                PresenterOfShareOptionsViewController.checkForImageAndUpload(
                    imagesToUpload: imagesToUpload,
                    viewController: viewController,
                    imageSelected: imageSelected)
            }
            // else delete the existing note and post a new one
        } else {
            
            func deleteNote() {
                
                // delete note
                NotesCachingWrapperHelper.deleteNote(noteID: receivedNote.noteID, userToken: userToken, userDomain: userDomain, cacheTypeID: "notes-Delete")
                
                PresenterOfShareOptionsViewController.checkForImageAndUpload(imagesToUpload: imagesToUpload, viewController: viewController, imageSelected: imageSelected)
            }
            
            // if note is shared and user has changed the text show alert message
            if cachedIsNoteShared && (receivedNote.data.message != textViewText) {
                
                viewController.createClassicAlertWith(
                    alertMessage: "Your post would not be edited at the destination.",
                    alertTitle: "",
                    cancelTitle: "Cancel",
                    proceedTitle: "OK",
                    proceedCompletion: deleteNote,
                    cancelCompletion: {
                        
                        PresenterOfShareOptionsViewController.restorePublishButtonToPreviousState(
                            isUserInteractionEnabled: true,
                            previousTitle: previousPublishButtonTitle,
                            publishButton: publishButton)
                    }
                )
                // if note is shared show message
            } else if receivedNote.data.shared {
                
                viewController.createClassicAlertWith(
                    alertMessage: "You are about to share your post. \n\nTip: to remove a note from the external site, edit the note and make it private.",
                    alertTitle: "",
                    cancelTitle: "Cancel",
                    proceedTitle: "Share now",
                    proceedCompletion: deleteNote,
                    cancelCompletion: {
                        
                        PresenterOfShareOptionsViewController.restorePublishButtonToPreviousState(
                            isUserInteractionEnabled: true,
                            previousTitle: previousPublishButtonTitle,
                            publishButton: publishButton)
                    }
                )
            } else {
                
                deleteNote()
            }
        }
    }
    
    class func checkIfReauthorisationIsNeeded(viewController: ShareOptionsViewController, publishButton: UIButton, completion: @escaping (String?) -> Void) -> () -> Void {
        
        return {
            
            var fakeInout = ""
            let authoriseVC = AuthoriseUserViewController()
            authoriseVC.view.frame = CGRect(x: viewController.view.center.x - 50, y: viewController.view.center.y - 20, width: 100, height: 40)
            authoriseVC.view.layer.cornerRadius = 15
            authoriseVC.completionFunc = completion
            
            // add the page view controller to self
            viewController.addChildViewController(authoriseVC)
            viewController.view.addSubview(authoriseVC.view)
            authoriseVC.didMove(toParentViewController: viewController)
            
            PresenterOfShareOptionsViewController.changePublishButtonTo(
                title: "Please try again",
                userEnabled: true,
                publishButton: publishButton, previousTitle: &fakeInout)
        }
    }
    
    class func checkNoteIsDeletable(viewController: ShareOptionsViewController, cachedIsNoteShared: Bool, proceedCompletion: @escaping () -> Void) {
        
        // if note shared show message
        if cachedIsNoteShared {
            
            viewController.createClassicAlertWith(
                alertMessage: "Deleting a note that has already been shared will not delete it at the destination. \n\nTo remove a note from the external site, first make it private. You may then choose to delete it.",
                alertTitle: "",
                cancelTitle: "Cancel",
                proceedTitle: "Proceed",
                proceedCompletion: proceedCompletion,
                cancelCompletion: {})
        } else {
            
            proceedCompletion()
        }
    }
    
    class func checkIfNoteIsShared(viewController: ShareOptionsViewController, cachedIsNoteShared: Bool, publicSwitchState: Bool, cancelCompletion: @escaping () -> Void, proccedCompletion: @escaping () -> Void) {
        
        if cachedIsNoteShared && !publicSwitchState {
            
            viewController.createClassicAlertWith(alertMessage: "This will remove your post at the shared destinations. \n\nWarning: any comments at the destinations would also be deleted.", alertTitle: "", cancelTitle: "Cancel", proceedTitle: "Proceed", proceedCompletion: proccedCompletion, cancelCompletion: cancelCompletion)
        } else {
            
            proccedCompletion()
        }
    }
    
    class func handleImageInit(selectedImage: UIImage?, imageView: UIImageView?, images: inout [UIImage], collectionView: UICollectionView, imageURL: String?) {
        
        if selectedImage != nil {
            
            imageView?.image = selectedImage
            images.append((imageView?.image!)!)
            collectionView.isHidden = false
        } else if URL(string: (imageURL)!) != nil {
            
            collectionView.isHidden = false
            images.append(UIImage(named: Constants.ImageNames.placeholderImage)!)
            collectionView.reloadData()
        }
    }
    
    class func checkIfNoteHasExpired(date: Date?, durationLabel: UILabel, shareForLabel: UILabel, isNoteShared: Bool) {
        
        if let unwrappedDate = date {
            
            if unwrappedDate > Date() && isNoteShared {
                
                durationLabel.text = FormatterHelper.formatDateStringToUsersDefinedDate(date: unwrappedDate, dateStyle: .short, timeStyle: .none)
                shareForLabel.text = "Shared until"
            } else if isNoteShared {
                
                durationLabel.text = FormatterHelper.formatDateStringToUsersDefinedDate(date: unwrappedDate, dateStyle: .short, timeStyle: .none)
                shareForLabel.text = "Expired on"
            }
        }
    }
    
    class func setImageLabelsOn(isNotePublicLabel: UILabel, shareNoteLabel: UILabel, color: UIColor) {
        
        // set image fonts
        isNotePublicLabel.attributedText = NSAttributedString(string: "\u{1F512}", attributes: [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: UIFont(name: Constants.FontNames.ssGlyphishFilled, size: 22)!])
        isNotePublicLabel.sizeToFit()
        
        shareNoteLabel.attributedText = NSAttributedString(string: "\u{23F2}", attributes: [NSAttributedStringKey.foregroundColor: color, NSAttributedStringKey.font: UIFont(name: Constants.FontNames.ssGlyphishFilled, size: 22)!])
        shareNoteLabel.sizeToFit()
    }
    
    class func setTitleOnPublishButtonBasedOn(isShared: Bool, button: UIButton) {
        
        if isShared {
            
            button.setTitle("Save", for: .normal)
        } else {
            
            button.setTitle("Share", for: .normal)
        }
    }
    
    class func initOnViewDidAppear(textView: UITextView, locationData: HATNotesLocationData, locationButton: UIButton) {
        
        // if no text add a placeholder
        if textView.text == "" {
            
            textView.textColor = .lightGray
            textView.text = "What's on your mind?"
        }
        
        if locationData.accuracy != 0 && locationData.latitude != 0 && locationData.latitude != 0 {
            
            locationButton.setImage(UIImage(named: Constants.ImageNames.gpsFilledImage), for: .normal)
        }
    }
    
    class func showProgressRing(loadingScr: inout LoadingScreenWithProgressRingViewController?, viewController: ShareOptionsViewController) {
        
        loadingScr = LoadingScreenWithProgressRingViewController.customInit(completion: 0, from: viewController.storyboard!)
        
        loadingScr!.view.createFloatingView(frame:CGRect(x: viewController.view.frame.midX - 75, y: viewController.view.frame.midY - 160, width: 150, height: 160), color: .teal, cornerRadius: 15)
        
        viewController.addViewController(loadingScr!)
    }
    
    class func updateProgressRing(loadingScr: LoadingScreenWithProgressRingViewController?, completion: Double) {
        
        let endPoint = loadingScr?.getRingEndPoint()
        loadingScr?.updateView(completion: completion, animateFrom: Float((endPoint)!), removePreviousRingLayer: false)
    }
    
    class func areButtonsEnabled(_ isEnabled: Bool, buttons: [UIButton]) {
        
        for button in buttons {
            
            button.isUserInteractionEnabled = isEnabled
        }
    }
    
    class func setUpLabels(publicLabel: UILabel, shareWithLabel: UILabel, shareForLabel: UILabel, publicText: String, color: UIColor) {
        
        // set the text of the public label
        publicLabel.text = publicText
        // set the colors of the labels
        shareWithLabel.textColor = color
        shareForLabel.textColor = color
    }
    
    class func updateSelectedFiles(_ selectedFiles: [FileUploadObject], imageSelected: UIImageView, collectionView: UICollectionView, imagesToUpload: inout [UIImage], completion: @escaping (UIImage) -> Void) {
        
        if !selectedFiles.isEmpty {
            
            let file = selectedFiles[0]
            if file.image != UIImage(named: Constants.ImageNames.placeholderImage) {
                
                imageSelected.image = file.image
                
                imagesToUpload.append(file.image!)
                collectionView.isHidden = false
                collectionView.reloadData()
            } else {
                
                if let url = URL(string: Constants.HATEndpoints.fileInfoURL(fileID: file.fileID, userDomain: userDomain)) {
                    
                    imageSelected.downloadedFrom(
                        url: url,
                        userToken: userToken,
                        progressUpdater: nil,
                        completion: {
                        
                            completion(imageSelected.image!)
                        }
                    )
                }
            }
        }
    }
    
    class func checkFilePublicOrPrivate(fileUploaded: FileUploadObject, receivedNote: inout HATNotesData, viewController: ShareOptionsViewController?, success: (() -> Void)? = nil) {
        
        if receivedNote.data.shared {
            
            // do another call to make image public
            HATFileService.makeFilePublic(
                fileID: fileUploaded.fileID,
                token: userToken,
                userDomain: userDomain,
                successCallback: { boolResult in
            
                    if boolResult {
                        
                        success?()
                    }
                },
                errorCallBack: {(error) -> Void in
                
                    CrashLoggerHelper.hatErrorLog(error: error)
                }
            )
        } else {
            
            HATFileService.makeFilePrivate(fileID: fileUploaded.fileID, token: userToken, userDomain: userDomain, successCallback: { boolResult in
                
                if boolResult {
                    
                    success?()
                }
            }, errorCallBack: {(error) -> Void in
                
                CrashLoggerHelper.hatErrorLog(error: error)
            })
        }
        
        // add image to note
        receivedNote.data.photoData.link = Constants.HATEndpoints.fileInfoURL(fileID: fileUploaded.fileID, userDomain: userDomain)
        
        // post note
        viewController?.postNote()
    }
    
    class func turnButtonOn(button: UIButton) {
        
        button.alpha = 1
    }
    
    class func turnButtonOff(button: UIButton) {
        
        button.alpha = 0.4
    }
    
}
