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
import SwiftyJSON

// MARK: Class

/// A class responsible for the profile picture UIViewController of the PHATA section
internal class PhataPictureViewController: UIViewController, UserCredentialsProtocol, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, PhotoPickerDelegate, SelectedPhotosProtocol {

    // MARK: - Protocol's Variables
    
    /// User's selected files
    var selectedFiles: [FileUploadObject] = []
    
    /// User's selected photos
    var selectedPhotos: [UIImage] = []
    
    // MARK: - Variables
    
    /// The loading view pop up
    private var loadingView: UIView = UIView()
    /// A dark view covering the collection view cell
    private var darkView: UIView = UIView()
    
    /// The image file received from the HAT containing info about the current profile picture and the selected pictures
    private var image: ProfileImageObject = ProfileImageObject()
    
    /// The selected image file to view full screen
    private var selectedFileToView: FileUploadObject?
    
    /// The Photo picker used to upload a new photo
    private let photoPicker: PhotosHelperViewController = PhotosHelperViewController()
    
    /// User's profile passed on from previous view controller
    var profile: HATProfileObject?
    
    // MARK: - IBoutlets

    /// An IBOutlet for handling the image view
    @IBOutlet private weak var imageView: UIImageView!
    
    /// An IBOutlet for handling the custom switch
    @IBOutlet private weak var customSwitch: CustomSwitch!
    
    /// An IBOutlet for handling the collectionView
    @IBOutlet private weak var collectionView: UICollectionView!
    
    // MARK: - IBActions
    
    /**
     Sets the isPrivate according to the value of the switch
     
     - parameter sender: The object that calls this function
     */
    @IBAction func customSwitchAction(_ sender: Any) {
        
        self.profile?.data.facebookProfilePhoto.isPrivate = !(self.customSwitch.isOn)
        if (profile?.data.isPrivate)! && self.customSwitch.isOn {
            
            profile?.data.isPrivate = false
        }
    }
    
    /**
     Presents a pop up with the possible ways of adding pictures
     
     - parameter sender: The object that calls this function
     */
    @IBAction func addImageButtonAction(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Select options", message: "Select from where to upload image", preferredStyle: .actionSheet)
        
        // create alert actions
        let cameraAction = UIAlertAction(title: "Take photo", style: .default, handler: { [unowned self] (_) -> Void in
            
            let photoPickerContorller = self.photoPicker.presentPicker(sourceType: .camera)
            self.present(photoPickerContorller, animated: true, completion: nil)
        })
        
        let libraryAction = UIAlertAction(title: "Choose from library", style: .default, handler: { [unowned self] (_) -> Void in
            
            let photoPickerContorller = self.photoPicker.presentPicker(sourceType: .photoLibrary)
            self.present(photoPickerContorller, animated: true, completion: nil)
        })
        
        let selectFromHATAction = UIAlertAction(title: "Choose from HAT", style: .default, handler: { [unowned self] (_) -> Void in
            
            self.performSegue(withIdentifier: Constants.Segue.profileToHATPhotosSegue, sender: self)
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addActions(actions: [cameraAction, libraryAction, selectFromHATAction, cancel])
        if let button = sender as? UIButton {
            
            alertController.addiPadSupport(sourceRect: button.frame, sourceView: button)
        }
        
        // present alert controller
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    /**
     Sends the profile data to hat
     
     - parameter sender: The object that calls this function
     */
    @IBAction func saveButtonAction(_ sender: Any) {
        
        self.darkView = UIView(frame: self.view.frame)
        self.darkView.backgroundColor = .black
        self.darkView.alpha = 0.4
        
        self.view.addSubview(self.darkView)
        
        self.loadingView = UIView.createLoadingView(
            with: CGRect(x: (self.view?.frame.midX)! - 70, y: (self.view?.frame.midY)! - 15, width: 140, height: 30),
            color: .teal,
            cornerRadius: 15,
            in: self.view,
            with: "Updating profile...",
            textColor: .white,
            font: UIFont(name: Constants.FontNames.openSans, size: 12)!)
        
        func tableExists(dict: Dictionary<String, Any>, renewedUserToken: String?) {
            
            func profilePosted() {
                
                self.loadingView.removeFromSuperview()
                self.darkView.removeFromSuperview()
                
                _ = self.navigationController?.popViewController(animated: true)
            }
            
            HATPhataService.postProfile(
                userDomain: userDomain,
                userToken: userToken,
                hatProfile: self.profile!,
                successCallBack: profilePosted,
                errorCallback: error
            )
        }
        
        func error(error: HATTableError) {
            
            self.loadingView.removeFromSuperview()
            self.darkView.removeFromSuperview()
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
        
        HATAccountService.checkHatTableExistsForUploading(
            userDomain: userDomain,
            tableName: Constants.HATTableName.Profile.name,
            sourceName: Constants.HATTableName.Profile.source,
            authToken: userToken,
            successCallback: tableExists,
            errorCallback: error
        )
        
        self.setAsProfile()
    }
    
    // MARK: - View controller methods
    
    func profileImageTapped() {
        
        let alertController = UIAlertController(title: "Options", message: "Please select one option", preferredStyle: .actionSheet)
        
        // create alert actions
        let removeAction = UIAlertAction(title: "Remove profile photo", style: .default, handler: { [unowned self] (_) -> Void in
            
            self.imageView.image = UIImage(named: Constants.ImageNames.placeholderImage)
            self.image.profileImage = nil
        })
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addActions(actions: [removeAction, cancel])
        alertController.addiPadSupport(sourceRect: self.imageView.frame, sourceView: self.imageView)
        
        // present alert controller
        self.navigationController!.present(alertController, animated: true, completion: nil)
    }
    
    func handleLongTapGesture(gesture: UILongPressGestureRecognizer) {
        
        switch gesture.state {
            
        case .began:
            
            guard let selectedIndexPath = self.collectionView.indexPathForItem(at: gesture.location(in: self.collectionView)) else { break }
            self.collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            
            self.collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            
            self.collectionView.endInteractiveMovement()
        default:
            
            self.collectionView.cancelInteractiveMovement()
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        photoPicker.delegate = self
        self.imageView.isUserInteractionEnabled = true
        
        let recogniser = UITapGestureRecognizer()
        recogniser.addTarget(self, action: #selector(profileImageTapped))
        self.imageView.addGestureRecognizer(recogniser)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongTapGesture(gesture:)))
        self.collectionView.addGestureRecognizer(longPressGesture)
        
        if self.profile == nil {
            
            self.profile = HATProfileObject()
        }
        
        self.customSwitch.isOn = !((profile?.data.facebookProfilePhoto.isPrivate)!)
        
        DispatchQueue.main.async {
            
            self.imageView.layer.masksToBounds = true
            self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        }
        
        self.getProfileImages()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Collection view
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.image.selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.Segue.profileImageHeader, for: indexPath) as? PhotosHeaderCollectionReusableView {
            
            return headerView.setUp(stringToShow: "My Profile Photos")
        }
        
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Constants.Segue.profileImageHeader, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let tempItem = self.image.selectedImages[sourceIndexPath.row]
        
        self.image.selectedImages.remove(at: sourceIndexPath.row)
        self.image.selectedImages.insert(tempItem, at: destinationIndexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.Segue.profilePictureCell, for: indexPath) as? PhotosCollectionViewCell
        
        return (cell?.setUpCell(
            userDomain: userDomain,
            userToken: userToken,
            files: self.image.selectedImages,
            indexPath: indexPath,
            completion: { [weak self] image in
            
                cell?.cropImage()
                
                self?.image.selectedImages[indexPath.row].image = image
            })
        )!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.selectedFileToView = self.image.selectedImages[indexPath.row]
        self.performSegue(withIdentifier: Constants.Segue.profilePhotoToFullScreenPhotoSegue, sender: self)
    }
    
    // MARK: - Image picker methods
    
    func didFinishWithError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        
        print("error")
    }
    
    func makeFilePublic(file: FileUploadObject, completion: @escaping (FileUploadObject) -> Void, failed: @escaping (HATError) -> Void) {
        
        func makeFilePublicSuccess(result: Bool) {
            
            var tempFile = file
            tempFile.contentPublic = result
            
            completion(tempFile)
        }
        
        func makeFilePublicFailed(error: HATError) {
            
            CrashLoggerHelper.hatErrorLog(error: error)
        }
        
        HATFileService.makeFilePublic(
            fileID: file.fileID,
            token: userToken,
            userDomain: userDomain,
            successCallback: makeFilePublicSuccess,
            errorCallBack: makeFilePublicFailed)
    }
    
    func didChooseImageWithInfo(_ info: [String : Any]) {
        
        func addFileToImages(file: FileUploadObject) {
            
            self.makeFilePublic(
                file: file,
                completion: { [weak self] file in
            
                    self?.image.selectedImages.append(file)
                    self?.collectionView.backgroundColor? = .white
                    self?.reloadCollectionView()
                    
                    self?.setAsProfile()
                },
                failed: { _ in return }
            )
        }
        
        photoPicker.handleUploadImage(
            info: info,
            name: String.random(length: 20),
            tags: ["iphone", "photo", "profile", "rumpel"],
            completion: addFileToImages,
            callingViewController: self,
            fromReference: self.photoPicker)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is PhotoFullScreenViewerViewController {
            
            weak var destinationVC = segue.destination as? PhotoFullScreenViewerViewController
            
            destinationVC?.file = self.selectedFileToView
            destinationVC?.image = self.selectedFileToView?.image
            destinationVC?.isImageForProfile = true
            destinationVC?.profileViewControllerDelegate = self
        } else if segue.destination is PhotoViewerViewController {
            
            weak var destinationVC = segue.destination as? PhotoViewerViewController
            
            destinationVC?.selectedPhotosDelegate = self
            destinationVC?.allowsMultipleSelection = true
        }
    }
    
    // MARK: - Delegate functions
    
    func setImageAsProfileImage(image: UIImage) {
        
        self.imageView.image = image
        self.imageView.cropImage(width: self.imageView.frame.width, height: self.imageView.frame.height)
    }
    
    func setImageAsProfileImage(file: FileUploadObject) {
        
        func execute(_ file: FileUploadObject) {
            
            if file.image != nil {
                
                self.imageView.image = file.image
                self.imageView.cropImage(width: self.imageView.frame.width, height: self.imageView.frame.height)
                
                self.image.profileImage = file
                self.reloadCollectionView()
                
                self.setAsProfile()
            } else {
                
                if let imageURL: URL = URL(string: Constants.HATEndpoints.fileInfoURL(fileID: file.fileID, userDomain: userDomain)) {
                    
                    self.imageView.downloadedFrom(
                        url: imageURL,
                        userToken: userToken,
                        progressUpdater: nil,
                        completion: { [weak self] in
                            
                            self?.image.profileImage = file
                            self?.reloadCollectionView()
                            
                            self?.setAsProfile()
                        }
                    )
                }
            }
        }
        
        if !file.contentPublic {
            
            self.makeFilePublic(
                file: file,
                completion: { file in
                    
                    execute(file)
                },
                failed: { _ in return }
            )
        } else {
            
            execute(file)
        }
    }
    
    func setSelectedFiles(files: [FileUploadObject]) {
        
        for file in files {
            
            self.setImageAsProfileImage(file: file)
        }
    }
    
    func setSelectedImages(images: [UIImage]) {
        
        print("yeah")
    }
    
    func deleteImage(file: FileUploadObject) {
        
    }
    
    func setAsProfile() {
        
        func valueCreated(result: JSON, renewedUserToken: String?) {
            
            print(result)
        }
        
        func failed(error: HATTableError) {
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
        
        for (index, file) in self.image.selectedImages.enumerated() {
            
            self.image.selectedImages[index].contentURL = Constants.HATEndpoints.fileInfoURL(fileID: file.fileID, userDomain: userDomain)
        }
        
        let parameters = self.image.toJSON()
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.ProfileImage.source,
            dataPath: Constants.HATTableName.ProfileImage.name,
            parameters: parameters,
            successCallback: valueCreated,
            errorCallback: failed)
    }
    
    private func reloadCollectionView() {
        
        DispatchQueue.main.async {
            
            self.collectionView.reloadData()
        }
    }
    
    func getProfileImages() {
        
        func success(json: [JSON], newToken: String?) {
            
            if !json.isEmpty {

                if let dict = (json[0].dictionary)?["data"]?.dictionary {
                    
                    self.image = ProfileImageObject(dictionary: dict)
                    if self.image.profileImage != nil {
                        
                        if let url = URL(string: self.image.profileImage!.contentURL) {
                            
                            self.imageView.downloadedFrom(
                                url: url,
                                userToken: userToken,
                                progressUpdater: nil,
                                completion: {
                                    
                                    self.imageView.cropImage(width: self.imageView.frame.width, height: self.imageView.frame.height)
                                }
                            )
                        }
                    }
                    self.collectionView.backgroundColor? = .white
                    self.reloadCollectionView()
                }
            } else {
                
                self.collectionView.backgroundColor? = .clear
            }
        }
        
        func failed(error: HATTableError) {
            
            CrashLoggerHelper.hatTableErrorLog(error: error)
        }
    
        HATAccountService.getHatTableValuesv2(
            token: userToken,
            userDomain: userDomain,
            source: Constants.HATTableName.ProfileImage.source,
            scope: Constants.HATTableName.ProfileImage.name,
            parameters: ["take": "1", "orderBy": "dateUploaded", "ordering": "descending"],
            successCallback: success,
            errorCallback: failed)
    }
    
}
