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

/// The social feed view controller class
internal class SocialFeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UserCredentialsProtocol {
    
    // MARK: - IBOutlets
    
    /// An IBOutlet for handling the empty collection view label
    @IBOutlet private weak var emptyCollectionViewLabel: UILabel!
    
    /// An IBOutlet for handling the collection view
    @IBOutlet private weak var collectionView: UICollectionView!
    
    /// An IBOutlet for handling the showAllNotes UIButton
    @IBOutlet private weak var showAllNotes: UIButton!
    /// An IBOutlet for handling the infoPopUpButton UIButton
    @IBOutlet private weak var infoPopUpButton: UIButton!
    /// An IBOutlet for handling the filterFeedButton UIButton
    @IBOutlet private weak var filterFeedButton: UIButton!
    
    @IBOutlet private weak var calendarImageView: UIImageView!
    
    @IBOutlet private weak var textField: UITextField!
    
    // MARK: - Variables
    
    /// An FacebookSocialFeedObject array to store all the posts from facebook
    private var posts: [HATFacebookSocialFeedObject] = []
    
    /// An TwitterSocialFeedObject array to store all the tweets from twitter
    private var tweets: [HATTwitterSocialFeedObject] = []
    
    /// An SocialFeedObject array to store all the date from both twitter and facebook
    private var allData: [HATSocialFeedObject] = []
    
    /// An SocialFeedObject array to cache all the date from both twitter and facebook
    private var cachedDataArray: [HATSocialFeedObject] = [] {
        
        didSet {
            
            if !cachedDataArray.isEmpty {
                
                DispatchQueue.main.async { [weak self] in
                    
                    if let weakSelf = self {
                        
                        weakSelf.collectionView.isHidden = false
                        weakSelf.emptyCollectionViewLabel.text = ""
                    }
                }
            }
        }
    }
    
    /// A String to filter the social feed by, Twitter, Facebook and All
    var filterBy: String = "All"
    /// A Bool to indicate if the filtering is enabled or not
    var isFilteringHidden: Bool = false
    
    /// A Bool to determine if twitter is available
    private var isTwitterAvailable: Bool = false
    
    private let datePicker: UIDatePicker = UIDatePicker()
    
    private let segmentControl: UISegmentedControl = UISegmentedControl(items: ["From", "To"])
    
    /// A String to define the end time of the last tweet in order to request tweets before this time
    private var twitterEndTime: String?
    /// A String to define the end time of the last tweet in order to request tweets before this time
    private var twitterStartTime: String = "0"
    /// A string to hold twitter app token for later use
    private var twitterAppToken: String = ""
    /// The preffered message of the info pop up view controller
    var prefferedInfoMessage: String = "Still work-in-progress, this is where you can see your social feed and notes."
    /// The preffered title of the view controller
    var prefferedTitle: String = "My Story"
    /// The number of items per request
    private var twitterLimitParameter: String = "50" {
        
        // every time this changes
        didSet {
            
            // fetch data from facebook with the saved token
            self.fetchTwitterData()
        }
    }
    
    /// The start date to filter for points
    private var filterDataPointsFrom: Date?
    /// The end date to filter for points
    private var filterDataPointsTo: Date?
    
    /// A Bool to determine if facebook is available
    private var isFacebookAvailable: Bool = false
    /// A Bool to hide or show the button depending if user came from dataplugs or not
    var showNotesButton: Bool = true
    
    /// An UIImageView to show the downloaded facebook profile image
    private var facebookProfileImage: UIImageView?
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    /// A String to define the end time of the last post in order to request posts before this time
    private var facebookEndTime: String?
    private var facebookStartTime: String?
    /// A string to hold facebook app token for later use
    private var facebookAppToken: String = ""
    /// The number of items per request
    private var facebookLimitParameter: String = "50" {
        
        // every time this changes
        didSet {
            
            // fetch data from facebook with the saved token
            self.fetchFacebookData()
        }
    }

    // MARK: - IBAction
    
    /**
     Shows an info pop up with a message
     
     - parameter sender: The object that called this method
     */
    @IBAction func infoButton(_ sender: Any) {
        
        self.showInfoViewController(text: prefferedInfoMessage)
        self.infoPopUpButton.isUserInteractionEnabled = false
    }
    
    /**
     Shows all available notes
     
     - parameter sender: The object that called this method
     */
    @IBAction func showAllNotesAction(_ sender: Any) {
        
        self.performSegue(withIdentifier: "socialFeedToNotesSegue", sender: self)
    }
    
    /**
     Shows a pop up with the available settings
     
     - parameter sender: The object that called this method
     */
    @IBAction func settingsButtonAction(_ sender: Any) {
        
        self.filterSocialNetworksButtonAction()
    }
    
    // MARK: - View Controller methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // view controller title
        self.title = self.prefferedTitle
        self.showAllNotes.isHidden = !self.showNotesButton
        
        let recogniser = UITapGestureRecognizer()
        recogniser.addTarget(self, action: #selector(self.selectDatesToViewLocations(gesture:)))
        self.calendarImageView.isUserInteractionEnabled = true
        self.calendarImageView.addGestureRecognizer(recogniser)
        
        self.createDatePickerAccessoryView()
        
        self.filterFeedButton.isHidden = self.isFilteringHidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
        
        // set datasource and delegate to self
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        self.hidesBottomBarWhenPushed = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        
        self.checkIfTokenExpired()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    override func willRotate(to toInterfaceOrientation: UIInterfaceOrientation, duration: TimeInterval) {
        
        // reload collection view to adjust the cells to the new width
        self.collectionView.reloadData()
    }
    
    // MARK: - Get Feed
    
    private func getFeed() {
        
        // show empty label
        showEptyLabelWith(text: "Checking data plugs....")
        
        self.fetchFacebookData()
        self.getFacebookProfileImage()
        self.fetchTwitterData()
    }
    
    // MARK: - Create Date Picker
    
    /**
     Creates the date picker for choosing dates to show location for
     */
    private func createDatePickerAccessoryView() {
        
        // Set some of UIDatePicker properties
        datePicker.frame = CGRect(x: 0, y: 200, width: view.frame.width, height: 220)
        datePicker.timeZone = NSTimeZone.local
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        
        // Add an event to call onDidChangeDate function when value is changed.
        datePicker.addTarget(
            self,
            action: #selector(self.datePickerValueChanged(sender:)),
            for: .valueChanged)
        
        let doneButton = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(self.donePickerButton(sender:)))
        doneButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        
        let spaceButton = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: nil,
            action: nil)
        spaceButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        
        self.segmentControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        self.segmentControl.selectedSegmentIndex = 0
        self.segmentControl.addTarget(self, action: #selector(segmentedControlDidChange(sender:)), for: UIControlEvents.valueChanged)
        self.segmentControl.tintColor = .teal
        
        let barButtonSegmentedControll = UIBarButtonItem(customView: segmentControl)
        
        let spaceButton2 = UIBarButtonItem(
            barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace,
            target: nil,
            action: nil)
        spaceButton2.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        
        let cancelButton = UIBarButtonItem(
            title: "Cancel",
            style: .done,
            target: self,
            action: #selector(self.cancelPickerButton(sender:)))
        cancelButton.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.teal], for: .normal)
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .toolbarColor
        toolBar.sizeToFit()
        
        toolBar.setItems([cancelButton, spaceButton, barButtonSegmentedControll, spaceButton2, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.textField.inputView = datePicker
        self.textField.inputAccessoryView = toolBar
    }
    
    // MARK: - Hidden Text Field method
    
    /**
     Init from and to values
     
     - parameter sender: The object that called this method
     */
    @objc
    func selectDatesToViewLocations(gesture: UITapGestureRecognizer) {
        
        self.textField.becomeFirstResponder()
        self.filterDataPointsFrom = Date().startOfTheDay()
        if let endOfDay = Date().endOfTheDay() {
            
            self.filterDataPointsTo = endOfDay
        }
    }
    
    // MARK: - Date picker method
    
    /**
     The method executed when the picker value changes to save the date to the correct value
     
     - parameter sender: The object that called this method
     */
    @objc
    func datePickerValueChanged(sender: UIDatePicker) {
        
        if self.segmentControl.selectedSegmentIndex == 0 {
            
            self.filterDataPointsFrom = self.datePicker.date.startOfTheDay()
            if let endOfDay = self.datePicker.date.endOfTheDay() {
                
                self.filterDataPointsTo = endOfDay
            }
        } else {
            
            if let endOfDay = self.datePicker.date.endOfTheDay() {
                
                self.filterDataPointsTo = endOfDay
            }
        }
    }
    
    // MARK: - Toolbar methods
    
    /**
     Called everytime the segmented control changes value. Saves the from and to date to filter the locations
     
     - parameter sender: The object that called this method
     */
    @objc
    func segmentedControlDidChange(sender: UISegmentedControl) {
        
        if self.segmentControl.selectedSegmentIndex == 0 {
            
            if self.filterDataPointsFrom != nil {
                
                self.datePicker.setDate(self.filterDataPointsFrom!, animated: true)
            }
        } else {
            
            if self.filterDataPointsTo != nil {
                
                self.datePicker.setDate(self.filterDataPointsTo!, animated: true)
            }
        }
    }
    
    /**
     The method executed when user taps the done button on the toolbar to filter the locations
     
     - parameter sender: The object that called this method
     */
    @objc
    func donePickerButton(sender: UIBarButtonItem) {
        
        self.textField.resignFirstResponder()
        
        NetworkHelper.stopBackgroundNetworkTasks()
        
        self.allData.removeAll()
        self.posts.removeAll()
        self.tweets.removeAll()
        self.cachedDataArray.removeAll()
        
        self.getFeed()
    }
    
    /**
     The method executed when user taps the cancel button on the toolbar to filter the locations
     
     - parameter sender: The object that called this method
     */
    @objc
    func cancelPickerButton(sender: UIBarButtonItem) {
        
        self.textField.resignFirstResponder()
        self.filterDataPointsFrom = nil
        self.filterDataPointsTo = nil
    }
    
    // MARK: - Fetch twitter data
    
    func constructTwitterParameters() -> Dictionary<String, String> {
        
        if self.twitterEndTime != nil {
            
            if self.filterDataPointsTo != nil && self.filterDataPointsFrom != nil {
                
                let tempStartTime = HATFormatterHelper.formatDateToEpoch(date: filterDataPointsFrom!)
                let tempEndTime = HATFormatterHelper.formatDateToEpoch(date: filterDataPointsTo!)
                
                if tempEndTime != nil && tempStartTime != nil {
                    
                    return ["limit": self.twitterLimitParameter,
                                   "endtime": self.twitterEndTime!,
                                   "starttime": tempStartTime!]
                } else {
                    
                    return ["limit": self.twitterLimitParameter,
                                   "endtime": self.twitterEndTime!,
                                   "starttime": "0"]
                }
            } else {
                
                return ["limit": self.twitterLimitParameter,
                               "endtime": self.twitterEndTime!,
                               "starttime": "0"]
            }
        } else {
            
            if self.filterDataPointsTo != nil && self.filterDataPointsFrom != nil {
                
                let tempStartTime = HATFormatterHelper.formatDateToEpoch(date: filterDataPointsFrom!)
                let tempEndTime = HATFormatterHelper.formatDateToEpoch(date: filterDataPointsTo!)
                
                if tempEndTime != nil && tempStartTime != nil {
                    
                    return ["limit": self.twitterLimitParameter,
                                   "endtime": tempEndTime!,
                                   "starttime": tempStartTime!]
                } else {
                    
                    return ["limit": self.twitterLimitParameter,
                                   "starttime": "0"]
                }
                
            } else {
                
                return ["limit": self.twitterLimitParameter,
                               "starttime": "0"]
            }
        }
    }
    
    /**
     Fetch twitter data
     
     - parameter appToken: The twitter app token
     */
    private func fetchTwitterData() {
        
        // show message that the social feed is downloading
        self.showEptyLabelWith(text: "Fetching social feed...")
        
        let parameters = self.constructTwitterParameters()
        
        SocialFeedCachingWrapperHelper.getTwitterFeed(
            userToken: userToken,
            userDomain: userDomain,
            cacheTypeID: "social-Twitter",
            parameters: parameters,
            successRespond: showTweets,
            failRespond: CrashLoggerHelper.JSONParsingErrorLogWithoutAlert)
    }
    
    func checkIfTokenExpired() {
        
        func success(token: String?) {
            
            self.getFeed()
        }
        
        func failed() {
            
            let authoriseVC = AuthoriseUserViewController()
            authoriseVC.view.frame = CGRect(x: self.view.center.x - 50, y: self.view.center.y - 20, width: 100, height: 40)
            authoriseVC.view.layer.cornerRadius = 15
            authoriseVC.completionFunc = success
            
            // add the page view controller to self
            self.addChildViewController(authoriseVC)
            self.view.addSubview(authoriseVC.view)
            authoriseVC.didMove(toParentViewController: self)
        }
        
        HATAccountService.checkIfTokenExpired(
            token: userToken,
            expiredCallBack: failed,
            tokenValidCallBack: success,
            errorCallBack: self.createClassicOKAlertWith)
    }
    
    /**
     Show the fetched tweets
     
     - parameter array: The array that the request returned
     */
    private func showTweets(array: [HATTwitterSocialFeedObject], renewedUserToken: String?) {
        
        // change flag
        self.isTwitterAvailable = true
        
        // check if the view is loaded and visible, else don't bother showing the data
        if self.isViewLoaded && (self.view.window != nil) {
            
            // switch to the background queue
            DispatchQueue.global().async { [weak self] () -> Void in
                
                if let weakSelf = self {
                    
                    // filter data from duplicates
                    var filteredArray = HATTwitterService.removeDuplicatesFrom(array: array)
                    
                    // sort array
                    filteredArray = (weakSelf.sortArray(array: filteredArray) as? [HATTwitterSocialFeedObject])!
                    
                    // for each dictionary parse it and add it to the array
                    for tweets in filteredArray {
                        
                        weakSelf.tweets.append(tweets)
                    }
                    
                    // if the returned array is equal or bigger than the defined limit make a new request with more data while this thread will continue to show that data
                    if array.count == Int(weakSelf.twitterLimitParameter) {
                        
                        // get the unix time stamp
                        let elapse = (filteredArray.last?.protocolLastUpdate)!.timeIntervalSince1970
                        
                        let temp = String(elapse)
                        
                        let array2 = temp.components(separatedBy: ".")
                        
                        // save the time stamp
                        weakSelf.twitterEndTime = array2[0]
                        
                        // increase the limit
                        weakSelf.twitterLimitParameter = "500"
                        
                        // removes duplicates
                        weakSelf.removeDuplicates()
                        
                        // rebuild data
                        weakSelf.rebuildDataArray(filter: weakSelf.filterBy)
                        // else nil the flags we use and reload collection view with the saved filter
                    } else {
                        
                        weakSelf.twitterEndTime = nil
                    }
                    
                    // removes duplicates
                    weakSelf.reloadCollectionView(with: weakSelf.filterBy)
                }
            }
        }
    }
    
    // MARK: - Fetch facebook data
    
    func constructFacebookParametersForRequest() -> Dictionary<String, String> {
        
        if self.facebookEndTime != nil {
            
            if self.filterDataPointsTo != nil && self.filterDataPointsFrom != nil {
                
                let tempStartTime = HATFormatterHelper.formatDateToEpoch(date: filterDataPointsFrom!)
                let tempEndTime = HATFormatterHelper.formatDateToEpoch(date: filterDataPointsTo!)
                
                if tempEndTime != nil && tempStartTime != nil {
                    
                    return ["limit": self.facebookLimitParameter,
                                   "endtime": self.facebookEndTime!,
                                   "starttime": tempStartTime!]
                } else {
                    
                    return ["limit": self.facebookLimitParameter,
                                   "endtime": self.facebookEndTime!,
                                   "starttime": "0"]
                }
            } else {
                
                return ["limit": self.facebookLimitParameter,
                               "endtime": self.facebookEndTime!,
                               "starttime": "0"]
            }
        } else {
            
            if self.filterDataPointsTo != nil && self.filterDataPointsFrom != nil {
                
                let tempStartTime = HATFormatterHelper.formatDateToEpoch(date: filterDataPointsFrom!)
                let tempEndTime = HATFormatterHelper.formatDateToEpoch(date: filterDataPointsTo!)
                
                if tempEndTime != nil && tempStartTime != nil {
                    
                    return ["limit": self.facebookLimitParameter,
                            "endtime": tempEndTime!,
                            "starttime": tempStartTime!]
                } else {
                    
                    return ["limit": self.facebookLimitParameter,
                                   "starttime": "0"]
                }
                
            } else {
                
                return ["limit": self.facebookLimitParameter,
                               "starttime": "0"]
            }
        }
    }
    
    /**
     Fetch facebook data
     
     - parameter appToken: The facebook app token
     */
    private func fetchFacebookData() {
        
        // show message that the social feed is downloading
        self.showEptyLabelWith(text: "Fetching social feed...")
        
        let parameters = self.constructFacebookParametersForRequest()
        
        SocialFeedCachingWrapperHelper.getFacebookFeed(
            userToken: userToken,
            userDomain: userDomain,
            cacheTypeID: "social-facebook",
            parameters: parameters,
            successRespond: showPosts,
            failRespond: CrashLoggerHelper.JSONParsingErrorLogWithoutAlert)
    }
    
    /**
     Fetch posts
     
     - parameter parameters: The url request parameters
     - returns: (Void) -> Void
     */
    private func getFacebookProfileImage() {
        
        if self.facebookProfileImage == nil {
            
            func setProfileImage(profileImage: [HATFacebookProfileImageObject], newToken: String?) {
                
                if profileImage[0].image != nil {
                    
                    self.facebookProfileImage = UIImageView()
                    self.facebookProfileImage?.image = profileImage[0].image
                }
            }
            
            SocialFeedCachingWrapperHelper.getFacebookProfilePicture(
                userToken: userToken,
                userDomain: userDomain,
                cacheTypeID: "facebook-picture",
                successRespond: setProfileImage)
        }
    }
    
    /**
     Show the fetched posts
     
     - parameter array: The array that the request returned
     */
    private func showPosts(array: [HATFacebookSocialFeedObject], renewedUserToken: String?) {
        
        // check if the view is loaded and visible, else don't bother showing the data
         if self.isViewLoaded && (self.view.window != nil) {
            
            // change flag
            self.isFacebookAvailable = true
            
            // switch to the background queue
            DispatchQueue.global().async { [weak self] () -> Void in
                
                if let weakSelf = self {
                    
                    // removes duplicates from parameter array
                    var filteredArray = HATFacebookService.removeDuplicatesFrom(array: array)
                    
                    // sort array
                    filteredArray = (weakSelf.sortArray(array: filteredArray) as? [HATFacebookSocialFeedObject])!
                        
                    // for each dictionary parse it and add it to the array
                    for posts in filteredArray {
                        
                        weakSelf.posts.append(posts)
                    }
                    
                    // if the returned array is equal or bigger than the defined limit make a new request with more data while this thread will continue to show that data
                    if array.count == Int(weakSelf.facebookLimitParameter) {
                        
                        // get the unix time stamp
                        let elapse = (filteredArray.last?.data.posts.createdTime)!.timeIntervalSince1970
                        
                        let temp = String(elapse)
                        
                        let array2 = temp.components(separatedBy: ".")
                        
                        // save the time stamp
                        weakSelf.facebookEndTime = array2[0]
                        
                        // increase the limit
                        weakSelf.facebookLimitParameter = "500"
                        
                        // removes duplicates
                        weakSelf.removeDuplicates()
                        
                        // rebuild data
                        weakSelf.rebuildDataArray(filter: weakSelf.filterBy)
                        // else nil the flags we use and reload collection view with the saved filter
                    } else {
                        
                        weakSelf.facebookEndTime = nil
                    }
                    
                    // removes duplicates
                    weakSelf.reloadCollectionView(with: weakSelf.filterBy)
                    
                    // refresh user token
                    KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
                }
            }
        }
    }
    
    // MARK: - Collection View methods

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.row < self.cachedDataArray.count {
            
            // if this index path is FacebookSocialFeedObject
            if let post = self.cachedDataArray[indexPath.row] as? HATFacebookSocialFeedObject {
                
                // create a cell
                var cell = SocialFeedCollectionViewCell()
                
                // if photo create a photo cell else create a status cell
                if post.data.posts.type == "photo" {
                    
                    cell = (collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.imageSocialFeedCell, for: indexPath) as? SocialFeedCollectionViewCell)!
                } else {
                    
                    cell = (collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.statusSocialFeedCell, for: indexPath) as? SocialFeedCollectionViewCell)!
                }
                
                // if we have a downloaded image show it
                if self.facebookProfileImage != nil {
                    
                    cell.setCellImage(image: self.facebookProfileImage?.image)
                }
                
                // return cell
                return SocialFeedCollectionViewCell.setUpCell(cell: cell, indexPath: indexPath, posts: post)
                // else this is a TwitterSocialFeedObject
            } else {
                
                // get TwitterSocialFeedObject
                let tweet = self.cachedDataArray[indexPath.row] as? HATTwitterSocialFeedObject
                
                // set up cell
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CellReuseIDs.statusSocialFeedCell, for: indexPath) as? SocialFeedCollectionViewCell
                
                // return cell
                return SocialFeedCollectionViewCell.setUpCell(cell: cell!, indexPath: indexPath, posts: tweet!)
            }
        }
        
        // return cell
        return SocialFeedCollectionViewCell.setUpCell(cell: SocialFeedCollectionViewCell(), indexPath: indexPath, posts: HATTwitterSocialFeedObject())
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.cachedDataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if self.cachedDataArray.count > indexPath.row {
            
            // if this index path is FacebookSocialFeedObject
            if let post = self.cachedDataArray[indexPath.row] as? HATFacebookSocialFeedObject {
                
                // if this is a photo post
                if post.data.posts.type == "photo" {
                    
                    // get message
                    var text = post.data.posts.message
                    
                    // if text is empty get story
                    if text == "" {
                        
                        text = post.data.posts.story
                    }
                    // if text is still empty get description
                    if text == "" {
                        
                        text = post.data.posts.description
                    }
                    
                    // calculate size of content
                    let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 20)
                    
                    // calculate size of image based on the image ratio
                    let imageHeight = collectionView.frame.width / 2.46
                    
                    // return size
                    return CGSize(width: collectionView.frame.width, height: 85 + size.height + imageHeight)
                }
                
                // else return size of text plus the cell
                let text = post.data.posts.description + "\n\n" + post.data.posts.link
                let size = self.calculateCellHeight(text: text, width: self.collectionView.frame.width - 20)
                
                return CGSize(width: collectionView.frame.width, height: 85 + size.height)
            } else {
                
                //return size of text plus the cell
                let tweet = self.cachedDataArray[indexPath.row] as? HATTwitterSocialFeedObject
                
                let text = tweet?.data.tweets.text
                let size = self.calculateCellHeight(text: text!, width: self.collectionView.frame.width - 20)
                
                return CGSize(width: collectionView.frame.width, height: 100 + size.height)
            }
        } else {
            
            return CGSize(width: collectionView.frame.width, height: 130)
        }
    }
    
    // MARK: - Calculate cell height
    
    /**
     Calculates the cell heigt
     
     - parameter text: The text we want to show
     - parameter width: The width of the field that will hold the text
     - returns: A CGSize object
     */
    private func calculateCellHeight(text: String, width: CGFloat) -> CGSize {
        
        return text.boundingRect(with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: nil, context: nil).size
    }
    
    // MARK: - Sort array
    
    /**
     Sorts array based on crated times
     
     - parameter array: The array to sort
     - returns: A sorted SocialFeedObject array based on crated times
     */
    private func sortArray(array: [HATSocialFeedObject]) -> [HATSocialFeedObject] {
        
        // the method to sort the array
        func sorting(first: HATSocialFeedObject, second: HATSocialFeedObject) -> Bool {
            
            // if first is FacebookSocialFeedObject
            if let postA = first as? HATFacebookSocialFeedObject {
                
                // if second is FacebookSocialFeedObject
                if let postB = second as? HATFacebookSocialFeedObject {
                    
                    // return true of false based on this result
                    return (postA.data.posts.createdTime)! > (postB.data.posts.createdTime)!
                // else second is TwitterSocialFeedObject
                } else {
                    
                    let tweetB = second as? HATTwitterSocialFeedObject
                    // return true of false based on this result
                    return (postA.data.posts.createdTime)! > (tweetB!.data.tweets.createdAt)!
                }
            // else first is TwitterSocialFeedObject
            } else {
                
                let tweetA = first as? HATTwitterSocialFeedObject
                
                // if second is FacebookSocialFeedObject
                if let postB = second as? HATFacebookSocialFeedObject {
                    
                    // return true of false based on this result
                    return (tweetA!.data.tweets.createdAt)! > (postB.data.posts.createdTime)!
                // if second is TwitterSocialFeedObject
                } else {
                    
                    let tweetB = second as? HATTwitterSocialFeedObject
                    // return true of false based on this result
                    return (tweetA?.data.tweets.createdAt)! > (tweetB!.data.tweets.createdAt)!
                }
            }
        }
        
        // sort array
        return array.sorted(by: sorting)
    }
    
    // MARK: - Reload collection view
    
    /**
     Reloads collection view based on a filter
     
     - parameter filter: The filter to reload the collection view with
     */
    private func reloadCollectionView(with filter: String) {
        
        // removes duplicates
        self.removeDuplicates()
        
        // rebuild data
        self.rebuildDataArray(filter: filter)
        
        // switch to the main thread to update stuff
        DispatchQueue.main.async {
            
            self.showEptyLabelWith(text: "")
            self.collectionView.reloadData()
        }
    }
    
    // MARK: - Remove duplicated
    
    /**
     Removes duplicates on twitter and facebook arrays
     */
    private func removeDuplicates() {
        
        self.posts = HATFacebookService.removeDuplicatesFrom(array: self.posts)
        self.tweets = HATTwitterService.removeDuplicatesFrom(array: self.tweets)
    }
    
    // MARK: - Rebuild data array
    
    /**
     Rebuild the data with the new filter
     
     - parameter filter: The filter to rebuild the data by
     */
    private func rebuildDataArray(filter: String) {
        
        // check the filter type and reload the data array
        if filter == "All" {
            
            for post in self.posts {
                
                self.allData.append(post as HATSocialFeedObject)
            }
            for tweet in self.tweets {
                
                self.allData.append(tweet)
            }
        } else if filter == "Twitter" {
            
            for tweet in self.tweets {
                
                self.allData.append(tweet)
            }
        } else if filter == "Facebook" {
            
            for post in self.posts {
                
                self.allData.append(post as HATSocialFeedObject)
            }
        }
        
        // sort data
        self.allData = self.sortArray(array: allData)
        
        // dump them in main array
        self.cachedDataArray = self.allData
        
        // remove data from data array
        self.allData.removeAll()
    }
    
    // MARK: - Filter social feed
    
    /**
     Creates an alert view controller to filter the social feed
     
     - parameter notification: The notification object
     */
    @objc
    private func filterSocialNetworksButtonAction() {
        
        func reloadCollectionViewBaseOnFilter(_ filter: String, viewController: SocialFeedViewController) {
            
            viewController.cachedDataArray.removeAll()
            
            if filter == "Facebook" {
                
                if !viewController.posts.isEmpty {
                    
                    for i in 0...viewController.posts.count - 1 {
                        
                        viewController.cachedDataArray.append(viewController.posts[i] as HATSocialFeedObject)
                    }
                }
            } else if filter == "Twitter" {
                
                if !viewController.tweets.isEmpty {
                    
                    for i in 0...viewController.tweets.count - 1 {
                        
                        viewController.cachedDataArray.append(viewController.tweets[i])
                    }
                }
            } else {
                
                if !viewController.tweets.isEmpty {
                    
                    for i in 0...viewController.tweets.count - 1 {
                        
                        viewController.cachedDataArray.append(viewController.tweets[i])
                    }
                }
                
                if !viewController.posts.isEmpty {
                    
                    for i in 0...viewController.posts.count - 1 {
                        
                        viewController.cachedDataArray.append(viewController.posts[i] as HATSocialFeedObject)
                    }
                }
            }
            
            viewController.filterBy = filter
            
            viewController.reloadCollectionView(with: viewController.filterBy)
        }
        
        // create alert
        let alert = UIAlertController(title: "Filter by:", message: "", preferredStyle: .actionSheet)
        
        // create actions
        let facebookAction = UIAlertAction(title: "Facebook", style: .default, handler: {[weak self] (_) -> Void in
            
            if let weakSelf = self {
                
                reloadCollectionViewBaseOnFilter("Facebook", viewController: weakSelf)
            }
        })
        
        let twitterAction = UIAlertAction(title: "Twitter", style: .default, handler: {[weak self] (_) -> Void in
            
             if let weakSelf = self {
                
                reloadCollectionViewBaseOnFilter("Twitter", viewController: weakSelf)
            }
        })
        
        let allNetworksAction = UIAlertAction(title: "All", style: .default, handler: {[weak self] (_) -> Void in
            
            if let weakSelf = self {
                
                reloadCollectionViewBaseOnFilter("All", viewController: weakSelf)
            }
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addActions(actions: [facebookAction, twitterAction, allNetworksAction, cancelAction])
        alert.addiPadSupport(sourceRect: self.filterFeedButton.bounds, sourceView: self.filterFeedButton)
        
        // present alert view controller
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Show empty label
    
    /**
     Shows a message in the emptyLabel if something is wrong
     
     - parameter text: The string to show to the empty label
     */
    private func showEptyLabelWith(text: String) {
        
        DispatchQueue.main.async {[weak self] in
            
            if let weakSelf = self {
                
                if !(weakSelf.isTwitterAvailable) && !(weakSelf.isFacebookAvailable) {
                    
                    weakSelf.emptyCollectionViewLabel.text = text
                }
                
                if text == "" && (weakSelf.isTwitterAvailable || weakSelf.isFacebookAvailable) && weakSelf.cachedDataArray.count < 1 {
                    
                    weakSelf.emptyCollectionViewLabel.text = "No data found. If this is your first time installing the plug, it may take up to an hour before all your data comes in"
                } else if !weakSelf.cachedDataArray.isEmpty {
                    
                    weakSelf.emptyCollectionViewLabel.text = ""
                } else {
                    
                    weakSelf.emptyCollectionViewLabel.text = text
                }
            }
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
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(
            frame: CGRect(
                x: self.view.frame.origin.x + 15,
                y: self.collectionView.frame.maxY,
                width: self.view.frame.width - 30,
                height: self.view.frame.height),
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
                    animations: {
                        
                        textPopUpViewController?.view.frame = CGRect(
                            x: weakSelf.view.frame.origin.x + 15,
                            y: weakSelf.collectionView.frame.maxY - 150,
                            width: weakSelf.view.frame.width - 30,
                            height: 200)
                    },
                    completion: { _ in return }
                )
            }
        }
    }

}
