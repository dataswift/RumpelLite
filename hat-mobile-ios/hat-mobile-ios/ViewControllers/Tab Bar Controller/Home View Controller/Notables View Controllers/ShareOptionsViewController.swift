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

/// The share options view controller
internal class ShareOptionsViewController: UIViewController, UITextViewDelegate, PhotoPickerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, SendLocationDataDelegate, UserCredentialsProtocol, SelectedPhotosProtocol {
    
    // MARK: - Protocol's Methods
    
    func locationDataReceived(latitude: Double, longitude: Double, accuracy: Double) {
        
        self.receivedNote?.data.locationv1?.latitude = latitude
        self.receivedNote?.data.locationv1?.longitude = longitude
        self.receivedNote?.data.locationv1?.accuracy = accuracy
    }
    
    // MARK: - Protocol's Variables
    
    /// User's selected files
    var selectedFiles: [FileUploadObject] = [] {
        
        didSet {
            
            PresenterOfShareOptionsViewController.updateSelectedFiles(
                self.selectedFiles,
                imageSelected: self.imageSelected,
                collectionView: self.collectionView,
                imagesToUpload: &self.imagesToUpload,
                completion: {image in
                
                    self.imagesToUpload.append(self.imageSelected.image!)
                    self.collectionView.isHidden = false
                    self.collectionView.reloadData()
                }
            )
        }
    }
    
    /// User's selected photos
    var selectedPhotos: [UIImage] = [] {
        
        didSet {
            
            self.imageSelected.image = self.selectedFiles[0].image
            
            self.imagesToUpload.append(self.selectedFiles[0].image!)
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }
    }

    // MARK: - Variables
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    /// A loading screen used while uploading photos
    private var loadingScr: LoadingScreenWithProgressRingViewController?
    
    /// The PhotosHelperViewController used to select photos from the Library
    private let photosViewController: PhotosHelperViewController = PhotosHelperViewController()
    
    /// An array of strings holding the selected social networks to share the note
    private var shareOnSocial: [String] = []
    
    /// An array of strings holding the available data plugs
    private var dataPlugs: [HATDataPlugObject] = []
    
    /// The images to upload to HAT
    private var imagesToUpload: [UIImage] = []
    
    /// A CGFloat to reposition the Action View if needed
    private var lastYPositionOfActionView: CGFloat = 0
    
    /// A variable holding the selected image from the image picker
    private var imageSelected: UIImageView = UIImageView()
    
    /// The currently selected Image
    var selectedImage: UIImage?
    
    /// A string passed from Notables view controller about the kind of the note
    var kind: String = "note"
    var prefferedTitle: String = "Note"
    var prefferedInfoMessage: String = "Post something on social media (FB or Twitter) or on HATTERS bulletin board. Share for 1/7/14/30 days and it would be deleted when the note expires! Or delete it instantly at the shared location by moving the note to private. Add your location or a photo!"
    
    /// The previous title for publish button
    private var previousPublishButtonTitle: String?
    
    /// the received note to edit from notables view controller
    var receivedNote: HATNotesV2Object?
    
    /// the cached received note to edit from notables view controller
    private var cachedIsNoteShared: Bool = false
    /// a bool value to determine if the user is editing an existing value
    var isEditingExistingNote: Bool = false
    /// a flag to define if the keyboard is visible
    private var isKeyboardVisible: Bool = false
    
    var autoSharedNote: Bool = false
    
    /// A reference to safari view controller in order to show or hide it
    private var dataPlugsResponseInteractor: DataPlugsResponseInteractor = DataPlugsResponseInteractor()
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the public/private label
    @IBOutlet private weak var publicLabel: UILabel!
    /// An IBOutlet for handling the public icon label
    @IBOutlet private weak var publicImageLabel: UILabel!
    /// An IBOutlet for handling the share for... icon label
    @IBOutlet private weak var shareImageLabel: UILabel!
    /// An IBOutlet for handling the share with label
    @IBOutlet private weak var shareWithLabel: UILabel!
    /// An IBOutlet for handling the share for... label
    @IBOutlet private weak var shareForLabel: UILabel!
    /// An IBOutlet for handling the durationSharedLabel
    @IBOutlet private weak var durationSharedForLabel: UILabel!
    
    /// An IBOutlet for handling the public/private switch
    @IBOutlet private weak var publicSwitch: UISwitch!
    
    /// An IBOutlet for handling collectionView
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// An IBOutlet for handling the delete button
    @IBOutlet private weak var deleteButtonOutlet: UIButton!
    /// An IBOutlet for handling the facebook button
    @IBOutlet private weak var facebookButton: UIButton!
    /// An IBOutlet for handling the twitter button
    @IBOutlet private weak var twitterButton: UIButton!
    /// An IBOutlet for handling the marketsquare button
    @IBOutlet private weak var marketsquareButton: UIButton!
    /// An IBOutlet for handling the publish button
    @IBOutlet private weak var publishButton: UIButton!
    /// An IBOutlet for handling the add button
    @IBOutlet private weak var addButton: UIButton!
    /// An IBOutlet for handling the add image Button
    @IBOutlet private weak var addImageButton: UIButton!
    /// An IBOutlet for handling the add location Button
    @IBOutlet private weak var addLocationButton: UIButton!
    /// An IBOutlet for handling the delete button
    @IBOutlet private weak var infoPopUpButton: UIButton!
    
    /// An IBOutlet for handling the stackView
    @IBOutlet private weak var stackView: UIStackView!
    
    /// An IBOutlet for handling the action view
    @IBOutlet private weak var actionsView: UIView!
    /// An IBOutlet for handling the shareForView
    @IBOutlet private weak var shareForView: UIView!
    /// An IBOutlet for handling the settingsContentView
    @IBOutlet private weak var settingsContentView: UIView!
    
    /// An IBOutlet for handling the scroll view
    @IBOutlet private weak var scrollView: UIScrollView!
    
    /// An IBOutlet for handling the UITextView
    @IBOutlet private weak var textView: UITextView!
    
    // MARK: - IBActions
    
    @IBAction func infoButtonAction(_ sender: Any) {
        
        self.showInfoViewController(text: prefferedInfoMessage)
        self.infoPopUpButton.isUserInteractionEnabled = false
    }
    
    /**
     This function is called when the user touches the add images button
     
     - parameter sender: The object that called this function
     */
    @IBAction func addImageButtonAction(_ sender: Any) {
        
        let alertController = PresenterOfShareOptionsViewController.createUploadPhotoOptionsAlert(
            sourceRect: self.addImageButton.bounds,
            sourceView: self.addImageButton,
            viewController: self,
            photosViewController: self.photosViewController)
        
        // present alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    /**
     This function is called when the user touches the add location button
     
     - parameter sender: The object that called this function
     */
    @IBAction func addLocationButtonAction(_ sender: Any) {
        
        if self.receivedNote?.data.locationv1?.latitude != 0 && self.receivedNote?.data.locationv1?.longitude != 0 && self.receivedNote?.data.locationv1?.accuracy != 0 {
            
            self.receivedNote?.data.locationv1?.latitude = 0
            self.receivedNote?.data.locationv1?.longitude = 0
            self.receivedNote?.data.locationv1?.accuracy = 0
            
            self.addLocationButton.setImage(UIImage(named: Constants.ImageNames.addLocation), for: .normal)
        } else if Reachability.isConnectedToNetwork() {
            
            self.performSegue(withIdentifier: Constants.Segue.checkInSegue, sender: self)
        } else {
            
            self.createClassicOKAlertWith(
                alertMessage: "Please connect to the internet and try again",
                alertTitle: "Not connected to the internet",
                okTitle: "OK",
                proceedCompletion: {})
        }
    }
    
    /**
     This function is called when the user touches the twitter button
     
     - parameter sender: The object that called this function
     */
    @IBAction func twitterButtonAction(_ sender: Any) {
        
        // if button is enabled
        if self.twitterButton.isUserInteractionEnabled {
            
            // if button was selected deselect it and remove the button from the array
            if self.twitterButton.alpha == 1 {
                
                self.shareOnSocial.removeThe(string: "twitter")
                PresenterOfShareOptionsViewController.turnButtonOff(button: self.twitterButton)
                self.receivedNote?.data.shared_on = self.shareOnSocial
                // else select it and add it to the array
            } else {
                
                // check data plug
                func checkDataPlug(plug: HATDataPlugObject, appToken: String, renewedUserToken: String?) {
                    
                    self.dataPlugsResponseInteractor = DataPlugsResponseInteractor(forPlug: "twitter")
                    self.dataPlugsResponseInteractor.dataPlugTokenReceived(
                        plug: plug,
                        button: self.twitterButton,
                        publishButton: self.publishButton,
                        viewController: self,
                        token: appToken,
                        renewedUserToken: renewedUserToken,
                        isPlugEnabledResult: { [weak self] _ in
                    
                            if let weakSelf = self {
                                
                                weakSelf.shareOnSocial.append("twitter")
                                // construct string from the array and save it
                                weakSelf.receivedNote?.data.shared_on = weakSelf.shareOnSocial
                            }
                        }
                    )
                }
                
                PresenterOfShareOptionsViewController.changePublishButtonTo(
                    title: "Please Wait..",
                    userEnabled: false,
                    publishButton: self.publishButton,
                    previousTitle: &self.previousPublishButtonTitle!)
                
                for plug in self.dataPlugs where plug.plug.name == "twitter" {
                    
                    // get app token for twitter
                    HATTwitterService.getAppTokenForTwitter(
                        plug: plug,
                        userDomain: userDomain,
                        token: userToken,
                        successful: { appToken, newToken in
                            
                            checkDataPlug(plug: plug, appToken: appToken, renewedUserToken: newToken)
                        },
                        failed: { [weak self] (error) in
                            
                            // if something wrong show error
                            self?.createClassicOKAlertWith(alertMessage: "There was an error checking for data plug. Please try again later.", alertTitle: "Failed checking Data plug", okTitle: "OK", proceedCompletion: {})
                            
                            // reset ui
                            self?.turnUIElementsOn()
                            
                            CrashLoggerHelper.JSONParsingErrorLogWithoutAlert(error: error)
                        }
                    )
                }
                
                PresenterOfShareOptionsViewController.turnButtonOn(
                    button: self.twitterButton)
            }
        }
    }
    
    /**
     This function is called when the user touches the duration button
     
     - parameter sender: The object that called this function
     */
    @IBAction func shareForDurationAction(_ sender: Any) {
        
        self.textView.resignFirstResponder()
        // create alert controller
        let alertController = PresenterOfShareOptionsViewController.createShareForDurationAlertController(
            sourceRect: self.durationSharedForLabel.bounds,
            sourceView: self.shareForView,
            viewController: self)
        
        // present alert controller
        self.present(alertController, animated: true, completion: nil)
    }
    
    func postNote(updatedLink: String? = nil) {
        
        if updatedLink != nil {
            
            self.receivedNote?.data.photov1 = HATNotesV2PhotoObject()
            self.receivedNote?.data.photov1?.link = updatedLink!
        }
        
        // save text
        self.receivedNote?.data.message = self.textView.text!
        
        NotesCachingWrapperHelper.postNote(
            note: self.receivedNote!,
            userToken: self.userToken,
            userDomain: self.userDomain,
            successCallback: { [weak self] in
                
                guard let weakSelf = self else {
                    
                    return
                }
                
                weakSelf.loadingScr?.removeFromParentViewController()
                weakSelf.loadingScr?.view.removeFromSuperview()
                _ = weakSelf.navigationController?.popViewController(animated: true)
                
                if weakSelf.isEditingExistingNote {
                    
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: Constants.NotificationNames.reloadTable), object: nil)
                    weakSelf.isEditingExistingNote = false
                }
            },
            errorCallback: { _ in return }
        )
    }
    
    func uploadImage() {
        
        PresenterOfShareOptionsViewController.showProgressRing(loadingScr: &self.loadingScr, viewController: self)
        
        //self.receivedNote?.data.photoData.image = self.imageSelected.image
        
        HATFileService.uploadFileToHATWrapper(
            token: userToken,
            userDomain: userDomain,
            fileToUpload: self.imageSelected.image!,
            tags: ["iphone", "notes", "photo"],
            progressUpdater: {[weak self](completion) -> Void in
                
                PresenterOfShareOptionsViewController.updateProgressRing(loadingScr: self?.loadingScr, completion: completion)
            },
            completion: {[weak self](fileUploaded, renewedUserToken) -> Void in
                
                if let weakSelf = self {
                    
                    PresenterOfShareOptionsViewController.checkFilePublicOrPrivate(fileUploaded: fileUploaded, receivedNote: weakSelf.receivedNote!, viewController: weakSelf)
                }
                // refresh user token
                KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
            },
            errorCallBack: {[weak self](error) -> Void in
                
                switch error {
                    
                case .noInternetConnection:
                    
                    self?.loadingScr?.removeFromParentViewController()
                    self?.loadingScr?.view.removeFromSuperview()
                    
                    self?.postNote()
                default:
                    
                    self?.loadingScr?.removeFromParentViewController()
                    self?.loadingScr?.view.removeFromSuperview()
                    
                    self?.createClassicOKAlertWith(alertMessage: "There was an error with the uploading of the file, please try again later", alertTitle: "Upload failed", okTitle: "OK", proceedCompletion: {})
                    
                    PresenterOfShareOptionsViewController.restorePublishButtonToPreviousState(
                        isUserInteractionEnabled: true,
                        previousTitle: (self?.previousPublishButtonTitle!)!,
                        publishButton: (self?.publishButton)!)
                    CrashLoggerHelper.hatTableErrorLog(error: error)
                }
            }
        )
    }
    
    /**
     This function is called when the user touches the share button
     
     - parameter sender: The object that called this function
     */
    @IBAction func shareButton(_ sender: Any) {
        
        func post(token: String?) {
            
            // hide keyboard
            self.textView.resignFirstResponder()
            
            PresenterOfShareOptionsViewController.changePublishButtonTo(
                title: "Saving...",
                userEnabled: false,
                publishButton: self.publishButton,
                previousTitle: &self.previousPublishButtonTitle!)
            
            PresenterOfShareOptionsViewController.test(viewController: self, receivedNote: self.receivedNote!, imagesToUpload: self.imagesToUpload, isEditingExistingNote: self.isEditingExistingNote, cachedIsNoteShared: self.cachedIsNoteShared, textViewText: self.textView.text!, publishButton: self.publishButton, previousPublishButtonTitle: self.previousPublishButtonTitle!, imageSelected: self.imageSelected)
        }
        
        // check if the token has expired
        HATAccountService.checkIfTokenExpired(
            token: userToken,
            expiredCallBack: PresenterOfShareOptionsViewController.checkIfReauthorisationIsNeeded(
                viewController: self,
                publishButton: self.publishButton,
                completion: post) as () -> Void,
            tokenValidCallBack: post,
            errorCallBack: self.createClassicOKAlertWith)
    }
    
    /**
     This function is called when the user touches the delete button
     
     - parameter sender: The object that called this function
     */
    @IBAction func deleteButton(_ sender: Any) {
        
        func delete(token: String?) {
            
            // if not a previous note then nothing to delete
            if isEditingExistingNote {
                
                func proceedCompletion() {
                    
                    // delete note
                    HATNotablesService.deleteNotesv2(noteIDs: [(receivedNote?.recordId)!], tkn: userToken, userDomain: userDomain)
                    
                    //go back
                    _ = self.navigationController?.popViewController(animated: true)
                }
                
                PresenterOfShareOptionsViewController.checkNoteIsDeletable(viewController: self, cachedIsNoteShared: self.cachedIsNoteShared, proceedCompletion: proceedCompletion)
            }
        }
        
        // check if the token has expired
        HATAccountService.checkIfTokenExpired(
            token: userToken,
            expiredCallBack: PresenterOfShareOptionsViewController.checkIfReauthorisationIsNeeded(viewController: self, publishButton: self.publishButton, completion: delete) as () -> Void,
            tokenValidCallBack: delete,
            errorCallBack: self.createClassicOKAlertWith)
    }
    
    func changeAllUIElementsOnSwitchChange(switchState: Bool) {
        
        if switchState {
            
            // update the ui accordingly
            self.turnUIElementsOn()
            self.turnImagesOn()
            self.receivedNote?.data.shared = true
        } else {
            
            // update the ui accordingly
            self.turnUIElementsOff()
            self.turnImagesOff()
            self.receivedNote?.data.shared = false
            self.durationSharedForLabel.text = "Forever"
        }
    }
    
    /**
     This function is called when the user switches the switch
     
     - parameter sender: The object that called this function
     */
    @IBAction func publicSwitchStateChanged(_ sender: Any) {
        
        // hide keyboard if active
        self.textView.resignFirstResponder()
        
        func proccedCompletion() {
            
            self.changeAllUIElementsOnSwitchChange(switchState: self.publicSwitch.isOn)
            for view in self.settingsContentView.subviews {
                
                self.settingsContentView.bringSubview(toFront: view)
            }
        }
        
        func cancelCompletion() {
            
            self.publicSwitch.isOn = true
        }
        
        PresenterOfShareOptionsViewController.checkIfNoteIsShared(viewController: self, cachedIsNoteShared: self.cachedIsNoteShared, publicSwitchState: self.publicSwitch.isOn, cancelCompletion: cancelCompletion, proccedCompletion: proccedCompletion)
    }
    
    /**
     This function is called when the user touches the facebook image
     
     - parameter sender: The object that called this function
     */
    @IBAction func facebookButton(_ sender: Any) {
        
        // if button is enabled
        if self.facebookButton.isUserInteractionEnabled {
            
            // if button was selected deselect it and remove the button from the array
            if self.facebookButton.alpha == 1 {
                
                self.shareOnSocial.removeThe(string: "facebook")
                PresenterOfShareOptionsViewController.turnButtonOff(button: self.facebookButton)
                self.receivedNote?.data.shared_on = self.shareOnSocial
            // else select it and add it to the array
            } else {
                
                func facebookTokenReceived(plug: HATDataPlugObject, token: String, renewedUserToken: String?) {
                    
                    self.dataPlugsResponseInteractor = DataPlugsResponseInteractor(forPlug: "facebook")
                    self.dataPlugsResponseInteractor.dataPlugTokenReceived(
                        plug: plug,
                        button: self.facebookButton,
                        publishButton: self.publishButton,
                        viewController: self,
                        token: token,
                        renewedUserToken: renewedUserToken,
                        isPlugEnabledResult: { [weak self] _ in
                        
                            if let weakSelf = self {
                                
                                weakSelf.shareOnSocial.append("facebook")
                                // construct string from the array and save it
                                weakSelf.receivedNote?.data.shared_on = weakSelf.shareOnSocial
                            }
                        }
                    )
                }
                
                self.publishButton.setTitle("Please Wait..", for: .normal)
                
                for plug in self.dataPlugs where plug.plug.name == "facebook" {
                    
                    HATFacebookService.getAppTokenForFacebook(
                        plug: plug,
                        token: userToken,
                        userDomain: userDomain,
                        successful: { appToken, newToken in
                           
                            facebookTokenReceived(plug: plug, token: appToken, renewedUserToken: newToken)
                        },
                        failed: {[weak self] (error) in
                            
                            self?.createClassicOKAlertWith(alertMessage: "There was an error checking for data plug. Please try again later.", alertTitle: "Failed checking Data plug", okTitle: "OK", proceedCompletion: {})
                            
                            CrashLoggerHelper.JSONParsingErrorLogWithoutAlert(error: error)
                        }
                    )
                    
                    PresenterOfShareOptionsViewController.turnButtonOn(button: self.facebookButton)
                }
            }
        }
    }
    
    /**
     This function is called when the user touches the marketsquare image
     
     - parameter sender: The object that called this function
     */
    @IBAction func marketSquareButton(_ sender: Any) {
        
        // if button is enabled
        if self.marketsquareButton.isUserInteractionEnabled {
            
            // if button was selected deselect it and remove the button from the array
            if self.marketsquareButton.alpha == 1 {
                
                self.shareOnSocial.removeThe(string: "marketsquare")
                PresenterOfShareOptionsViewController.turnButtonOff(button: self.marketsquareButton)
                // else select it and add it to the array
            } else {
                
                self.shareOnSocial.append("marketsquare")
                PresenterOfShareOptionsViewController.turnButtonOn(button: self.marketsquareButton)
            }
            
            // construct string from the array and save it
            self.receivedNote?.data.shared_on = self.shareOnSocial
        }
    }
    
    // MARK: - Image picker Controller
    
    func didFinishWithError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        if let error = error {
            
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    func didChooseImageWithInfo(_ info: [String : Any]) {
        
        if !self.imagesToUpload.isEmpty {
            
            self.imagesToUpload.removeAll()
        }
        
        if let image = (info[UIImagePickerControllerOriginalImage] as? UIImage) {
            
            self.imageSelected.image = image
            
            self.imagesToUpload.append(image)
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        } else {
            
            self.createClassicOKAlertWith(alertMessage: "Please select only images", alertTitle: "Wrong file type", okTitle: "OK", proceedCompletion: {})
        }
    }
    
    // MARK: - Ensure notables plug is enabled
    
    /**
     Checks if notables plug is enabled before use
     */
    private func ensureNotablesPlugEnabled() {
        
        // if something wrong show error
        let failCallBack = { [weak self] () -> Void in
            
            self?.createClassicOKAlertWith(
                alertMessage: "There was an error enabling data plugs, please go to web rumpel to enable the data plugs",
                alertTitle: "Data Plug Error",
                okTitle: "OK",
                proceedCompletion: {})
        }
        
        // check if data plug is ready
        HATDataPlugsService.ensureOffersReady(
            succesfulCallBack: { _ in },
            tokenErrorCallback: failCallBack,
            failCallBack: {error in
                
                switch error {
                    
                case .offerClaimed:
                    
                    break
                case .noInternetConnection:
                    
                    break
                default:
                    
                    failCallBack()
                }
            }
        )
    }
    
    // MARK: - Autogenerated
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.photosViewController.delegate = self
        self.ensureNotablesPlugEnabled()
        
        // set title in the navigation bar
        self.navigationItem.title = self.kind.capitalized
        
        PresenterOfShareOptionsViewController.setImageLabelsOn(
            isNotePublicLabel: self.publicImageLabel,
            shareNoteLabel: self.shareImageLabel,
            color: .lightGray)
        
        // add gesture recognizer to share For view
        let tapGestureToShareForAction = UITapGestureRecognizer(target: self, action: #selector (self.shareForDurationAction(_:)))
        tapGestureToShareForAction.cancelsTouchesInView = false
        self.shareForView.addGestureRecognizer(tapGestureToShareForAction)
        
        // add gesture recognizer to text view
        let tapGestureTextView = UITapGestureRecognizer(target: self, action: #selector (self.enableEditingTextView))
        tapGestureTextView.cancelsTouchesInView = false
        self.textView.addGestureRecognizer(tapGestureTextView)
        
        // change title in publish button
        self.publishButton.titleLabel?.minimumScaleFactor = 0.5
        self.publishButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // if user is editing existing note set up the values accordingly
        if isEditingExistingNote {
            
            self.setUpUIElementsFromReceivedNote(self.receivedNote!)
            self.cachedIsNoteShared = (self.receivedNote?.data.shared)!
            
            PresenterOfShareOptionsViewController.setTitleOnPublishButtonBasedOn(
                isShared: (self.receivedNote?.data.shared)!,
                button: self.publishButton)
            
            PresenterOfShareOptionsViewController.handleImageInit(
                selectedImage: self.selectedImage,
                imageView: self.imageSelected,
                images: &self.imagesToUpload,
                collectionView: self.collectionView,
                imageURL: self.receivedNote?.data.photov1?.link)
            
            self.previousPublishButtonTitle = self.publishButton.titleLabel?.text
            
            guard let publicUntil = self.receivedNote?.data.public_until,
                let publicUntilAsDouble = Double(publicUntil) else {
                
                return
            }
            
            let date = Date(timeIntervalSince1970: publicUntilAsDouble)
            
            PresenterOfShareOptionsViewController.checkIfNoteHasExpired(
                date: date,
                durationLabel: self.durationSharedForLabel,
                shareForLabel: self.shareForLabel,
                isNoteShared: self.receivedNote!.data.shared)
        // else init a new value
        } else {
            
            self.receivedNote = HATNotesV2Object()
            self.deleteButtonOutlet.isHidden = true
        }
        
        self.previousPublishButtonTitle = "Save"
        
        // save kind of note
        self.receivedNote?.data.kind = self.kind
        
        // add notification observers
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow2), name:NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name:NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide2), name:NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAlertForDataPlug), name: Notification.Name("dataPlugMessage"), object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // add keyboard handling
        self.hideKeyboardWhenTappedAround()
        
        if self.autoSharedNote {
            
            self.publicSwitch.isOn = self.autoSharedNote
            self.changeAllUIElementsOnSwitchChange(switchState: self.publicSwitch.isOn)
        }
        
        self.title = self.prefferedTitle
        
        PresenterOfShareOptionsViewController.initOnViewDidAppear(
            textView: self.textView,
            locationData: self.receivedNote?.data.locationv1,
            locationButton: self.addLocationButton)
    }
    
    func addViewToTextView() {
        
        let path = UIBezierPath(rect: CGRect(
            x: 0,
            y: 0,
            width: 100,
            height: 30)
        )
        self.textView.textContainer.exclusionPaths = [path]
        
        let testView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 100,
            height: 30)
        )
        testView.backgroundColor = .red
        
        let label = UILabel(frame: CGRect(
            x: 0,
            y: 0,
            width: 100,
            height: 30)
        )
        label.text = "Location"
        
        let button = UIButton(frame: CGRect(
            x: 80,
            y: 0,
            width: 20,
            height: 20))
        button.setImage(UIImage(named: Constants.ImageNames.notesImage), for: .normal)
        
        testView.addSubview(button)
        testView.addSubview(label)
        self.textView.addSubview(testView)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        
        self.loadingScr?.view.frame = CGRect(x: self.view.frame.midX - 75, y: self.view.frame.midY - 160, width: 150, height: 160)

        self.viewWillLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        
        if self.lastYPositionOfActionView != 0 && self.isKeyboardVisible {
            
            self.actionsView.frame.origin.y = self.lastYPositionOfActionView
        }
    }
    
    // MARK: - Safari View controller notification
    
    @objc
    func showAlertForDataPlug(notif: Notification) {
        
        dataPlugsResponseInteractor.dismissSafari(publishButton: self.publishButton)
    }
    
    // MARK: - Setup UI functins
    
    /**
     Update the ui from the received note
     */
    private func setUpUIElementsFromReceivedNote(_ receivedNote: HATNotesV2Object) {
        
        // add message to the text field
        self.textView.text = receivedNote.data.message
        // set public switch state
        self.publicSwitch.isOn = true
        self.publicSwitch.setOn(receivedNote.data.shared, animated: false)
        // if switch is on update the ui accordingly
        if self.publicSwitch.isOn {
            
            self.shareOnSocial = receivedNote.data.shared_on
            self.turnUIElementsOn()
            self.turnImagesOn()
        }
    }
    
    /**
     Turns on the ui elemets
     */
    private func turnUIElementsOn() {
        
        // enable share for view
        self.shareForView.isUserInteractionEnabled = true
        
        // show the duration shared label
        self.durationSharedForLabel.isHidden = false
        
        // set the text of the public label
        PresenterOfShareOptionsViewController.setUpLabels(publicLabel: self.publicLabel, shareWithLabel: self.shareWithLabel, shareForLabel: self.shareForLabel, publicText: "Shared", color: .black)
        
        // enable social images
        PresenterOfShareOptionsViewController.areButtonsEnabled(true, buttons: [self.facebookButton, self.twitterButton, self.marketsquareButton])
        
        // set image fonts
        PresenterOfShareOptionsViewController.setImageLabelsOn(isNotePublicLabel: self.publicImageLabel, shareNoteLabel: self.shareImageLabel, color: .teal)
        
        PresenterOfShareOptionsViewController.setTitleOnPublishButtonBasedOn(isShared: self.isEditingExistingNote, button: self.publishButton)
    }
    
    /**
     Turns off the ui elemets
     */
    private func turnUIElementsOff() {
        
        // disable share for view
        self.shareForView.isUserInteractionEnabled = false
        
        // hide the duration shared label
        self.durationSharedForLabel.isHidden = true
        
        PresenterOfShareOptionsViewController.setUpLabels(publicLabel: self.publicLabel, shareWithLabel: self.shareWithLabel, shareForLabel: self.shareForLabel, publicText: "Private", color: .lightGray)
        // set the text of the public label
        self.shareForLabel.text = "For how long..."
        
        // disable social images
        PresenterOfShareOptionsViewController.areButtonsEnabled(false, buttons: [self.facebookButton, self.twitterButton, self.marketsquareButton])
        
        // set image fonts
        PresenterOfShareOptionsViewController.setImageLabelsOn(isNotePublicLabel: self.publicImageLabel, shareNoteLabel: self.shareImageLabel, color: .lightGray)
        
        self.publishButton.setTitle("Save", for: .normal)
    }
    
    /**
     Turns on the images
     */
    private func turnImagesOn() {
        
        // check array for elements
        for socialName in self.shareOnSocial {
            
            // if facebook then enable facebook button
            if socialName == "facebook" {
                
                self.facebookButton.alpha = 1
            }
            //  enable marketsquare button
            if socialName == "marketsquare" {
                
                self.marketsquareButton.alpha = 1
            }
            //  enable marketsquare button
            if socialName == "twitter" {
                
                self.twitterButton.alpha = 1
            }
        }
    }
    
    /**
     Turns on the images
     */
    private func turnImagesOff() {
        
        // empty the array
        self.shareOnSocial.removeAll()
        // deselect buttons
        self.facebookButton.alpha = 0.4
        self.marketsquareButton.alpha = 0.4
        self.twitterButton.alpha = 0.4
    }
    
    func updateShareOptions(buttonTitle: String, byAdding: Calendar.Component?, value: Int?) {
        
        self.durationSharedForLabel.text = buttonTitle
        if byAdding != nil && value != nil {
            
            let date = Calendar.current.date(byAdding: byAdding!, value: value!, to: Date())!
            self.receivedNote?.data.public_until = HATFormatterHelper.formatDateToEpoch(date: date)
        }
        self.shareForLabel.text = "For how long..."
    }
    
    // MARK: - Keyboard handling
    
    @objc
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @objc
    func keyboardWillShow2(notification: NSNotification) {
        
        var userInfo = notification.userInfo!
        if let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            
            var keyboardFrame: CGRect = frame.cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            self.scrollView.contentInset.bottom = keyboardFrame.size.height
            
            let desiredOffset = CGPoint(x: 0, y: self.scrollView.contentInset.top)
            self.scrollView.setContentOffset(desiredOffset, animated: true)
            self.isKeyboardVisible = true
        }
    }
    
    @objc
    func keyboardDidShow(notification: NSNotification) {
        
        var userInfo = notification.userInfo!
        if let frame = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            
            var keyboardFrame: CGRect = frame.cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            UIView.animate(withDuration: 0.3, animations: {() -> Void in
                
                self.actionsView.frame.origin.y = keyboardFrame.origin.y - self.actionsView.frame.height
                self.lastYPositionOfActionView = self.actionsView.frame.origin.y
            })
        }
    }
    
    @objc
    func keyboardWillHide2(notification: NSNotification) {
        
        var userInfo = notification.userInfo!
        if let frame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue {
            
            var keyboardFrame: CGRect = frame.cgRectValue
            keyboardFrame = self.view.convert(keyboardFrame, from: nil)
            
            let contentInset: UIEdgeInsets = UIEdgeInsets.zero
            self.scrollView.contentInset = contentInset
            self.actionsView.frame.origin.y = self.view.frame.height - self.actionsView.frame.height
            self.lastYPositionOfActionView = self.actionsView.frame.origin.y
            self.isKeyboardVisible = false
        }
    }
    
    // MARK: - TextView Delegate methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "What's on your mind?" {
            
            textView.attributedText = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == "" {
            
            self.textView.textColor = .lightGray
            self.textView.text = "What's on your mind?"
        }
        
        self.textView.isEditable = false
    }
    
    @objc
    private func enableEditingTextView() {
        
        self.textView.isEditable = true
        
        textViewDidBeginEditing(self.textView)
        self.textView.becomeFirstResponder()
    }
    
    // MARK: - UICollectionView methods
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.imagesToUpload.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.addedImageCell, for: indexPath) as? ShareOptionsSelectedImageCollectionViewCell
        
        let tapGestureToShareForAction = UITapGestureRecognizer(target: self, action: #selector (self.didTapOnCell(sender:)))
        tapGestureToShareForAction.cancelsTouchesInView = false
        cell?.addGestureRecognizer(tapGestureToShareForAction)
        
        return (cell?.setUpCell(imagesToUpload: self.imagesToUpload, imageLink: self.receivedNote?.data.photov1?.link, indexPath: indexPath, completion: { image in
            
            self.imagesToUpload[0] = image
            self.selectedImage = image
        }))!
    }
    
    @objc
    func didTapOnCell(sender: UITapGestureRecognizer) {
        
        //using sender, we can get the point in respect to the table view
        let tapLocation = sender.location(in: self.collectionView)
        
        //if tapLocation.point.
        if tapLocation.x < 80 && tapLocation.y > 35 {
            
            //using the tapLocation, we retrieve the corresponding indexPath
            let indexPath = self.collectionView.indexPathForItem(at: tapLocation)
            
            self.selectedImage = self.imagesToUpload[(indexPath?.row)!]
            
            self.performSegue(withIdentifier: Constants.Segue.goToFullScreenSegue, sender: self)
        } else {
            
            self.imagesToUpload.removeAll()
            self.receivedNote?.data.photov1?.link = ""
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Remove pop up
    
    /**
     Hides pop up presented currently
     */
    @objc
    private func hidePopUp() {
        
        self.darkView?.removeFromSuperview()
        self.infoPopUpButton.isUserInteractionEnabled = true
    }
    
    // MARK: - Add blur View
    
    /**
     Adds blur to the view before presenting the pop up
     */
    private func addBlurToView() {
        
        self.darkView = AnimationHelper.addBlurToView(self.view)
    }
    
    /**
     Shows the pop up view controller with the info passed on
     
     - parameter text: A String to show in the view controller
     */
    private func showInfoViewController(text: String) {
        
        // set up page controller
        let textPopUpViewController = TextPopUpViewController.customInit(
            stringToShow: text,
            isButtonHidden: true,
            from: self.storyboard!)
        
        let calculatedHeight = textPopUpViewController!.getLabelHeight() + 220
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(
            frame: CGRect(
                x: self.view.frame.origin.x + 15,
                y: self.view.frame.maxY,
                width: self.view.frame.width - 30,
                height: calculatedHeight),
            color: .teal,
            cornerRadius: 15)
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                // add the page view controller to self
                weakSelf.addBlurToView()
                weakSelf.addViewController(textPopUpViewController!)
                AnimationHelper.animateView(
                    textPopUpViewController?.view,
                    duration: 0.2,
                    animations: {() -> Void in
                        
                        textPopUpViewController?.view.frame = CGRect(
                            x: weakSelf.view.frame.origin.x + 15,
                            y: weakSelf.view.frame.maxY + (calculatedHeight * 0.1) - calculatedHeight,
                            width: weakSelf.view.frame.width - 30,
                            height: calculatedHeight)
                    },
                    completion: { _ in return }
                )
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == Constants.Segue.checkInSegue {
            
            weak var checkInMapVC = segue.destination as? CheckInMapViewController
            
            checkInMapVC?.noteOptionsDelegate = self
        } else if segue.identifier == Constants.Segue.goToFullScreenSegue {
            
            weak var fullScreenPhotoVC = segue.destination as? PhotoFullScreenViewerViewController
            
            fullScreenPhotoVC?.image = self.selectedImage
        } else if segue.identifier == Constants.Segue.createNoteToHATPhotosSegue {
            
            weak var destinationVC = segue.destination as? PhotoViewerViewController
            
            destinationVC?.selectedPhotosDelegate = self
            destinationVC?.allowsMultipleSelection = true
        }
    }
}
