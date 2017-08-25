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
import SafariServices
import SwiftyJSON

// MARK: Notables ViewController

/// The notables view controller
internal class NotablesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UserCredentialsProtocol {
    
    // MARK: - Variables
    
    /// a cached array of the notes to display
    private var cachedNotesArray: [HATNotesData] = []
    /// an array of the notes to work on without touching the cachedNotesArray
    private var notesArray: [HATNotesData] = []
    
    /// A dark view covering the collection view cell
    private var darkView: UIVisualEffectView?
    
    /// the index of the selected note
    private var selectedIndex: Int?
    
    /// the kind of the note to create
    private var kind: String = "note"
    /// the notables fetch items limit
    private var notablesFetchLimit: String = "50"
    /// the notables fetch end date
    private var notablesFetchEndDate: String?
    var prefferedTitle: String = "Notes"
    var prefferedInfoMessage: String = "Daily log, diary and innermost thoughts can all go in here!"
    
    var privateNotesOnly: Bool = false
    
    /// the paramaters to make the request for fetching the notes
    private var parameters: Dictionary<String, String> = ["starttime": "0",
                                                          "limit": "50"]
    
    /// A static let variable pointing to the AuthoriseUserViewController for checking if token is active or not
    private static let authoriseVC: AuthoriseUserViewController = AuthoriseUserViewController()

    // MARK: - IBOutlets

    /// An IBOutlet for handling the table view
    @IBOutlet private weak var tableView: UITableView!
    
    /// An IBOutlet for handling the create new notes green view at the bottom of the screen
    @IBOutlet private weak var createNewNoteView: UIView!
    
    /// An IBOutlet for handling the create new note button
    @IBOutlet private weak var createNewNoteButton: UIButton!
    /// An IBOutlet for handling the info label when table view is empty or an error has occured
    @IBOutlet private weak var eptyTableInfoLabel: UILabel!
    
    /// An IBOutlet for handling the retry connecting button when an error has occured
    @IBOutlet private weak var retryConnectingButton: UIButton!

    @IBOutlet private weak var infoPopUpButton: UIButton!
    
    // MARK: - IBActions
    
    @IBAction func infoPopUp(_ sender: Any) {
        
        self.showInfoViewController(text: prefferedInfoMessage)
        self.infoPopUpButton.isUserInteractionEnabled = false
    }
    
    /**
     Try to reconnect to get notes
     
     - parameter sender: The object that calls this function
     */
    @IBAction func refreshTableButtonAction(_ sender: Any) {
        
        // hide retry connection button
        self.retryConnectingButton.isHidden = true
        
        // fetch notes
        self.connectToServerToGetNotes(result: nil)
        
        self.ensureNotablesPlugEnabled()
    }
    
    /**
     Go to New note and create a note
     
     - parameter sender: The object that calls this function
     */
    @IBAction func newNoteButton(_ sender: Any) {
        
        self.performSegue(withIdentifier: Constants.Segue.optionsSegue, sender: self)
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
        
        let calculatedHeight = textPopUpViewController!.getLabelHeight() + 120
        
        self.tabBarController?.tabBar.isUserInteractionEnabled = false
        
        textPopUpViewController?.view.createFloatingView(
            frame: CGRect(
                x: self.view.frame.origin.x + 15,
                y: self.tableView.frame.maxY,
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
                            y: weakSelf.tableView.frame.maxY + (calculatedHeight * 0.3) - calculatedHeight,
                            width: weakSelf.view.frame.width - 30,
                            height: calculatedHeight)
                },
                    completion: { _ in return }
                )
            }
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
                default:
                    
                    failCallBack()
                }
            }
        )
    }
    
    // MARK: - View Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // view controller title
        self.title = self.prefferedTitle
        
        // keep the green bar at the top
        self.view.bringSubview(toFront: createNewNoteView)
        
        // register observers for a notifications
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshData), name: NSNotification.Name(rawValue: Constants.NotificationNames.reloadTable), object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hidePopUp),
            name: NSNotification.Name(Constants.NotificationNames.hideDataServicesInfo),
            object: nil)
                
        self.createNewNoteButton.addBorderToButton(width: 0.5, color: .white)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // check token
        self.addChildViewController(NotablesViewController.authoriseVC)
        NotablesViewController.authoriseVC.checkToken(viewController: self)
        
        // fetch notes
        self.connectToServerToGetNotes(result: nil)
        
        self.ensureNotablesPlugEnabled()
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - Show Notes
    
    /**
     Shows the received notes
     
     - parameter notification: The notification object
     */
    private func showReceivedNotesFrom(array: [JSON]) {
        
        DispatchQueue.global().async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                // for each dictionary parse it and add it to the array
                for dict in array {
                    
                    let note = HATNotesData.init(dict: dict.dictionary!)
                    
                    if weakSelf.privateNotesOnly {
                        
                        if !note.data.shared {
                            
                            weakSelf.notesArray.append(note)
                        }
                    } else {
                        
                        weakSelf.notesArray.append(note)
                    }
                }
                
                DispatchQueue.main.async {
                    
                    // update UI
                    weakSelf.updateUI()
                }
            }
        }
    }
    
    /**
     Refreshes the table per new data request
     
     - parameter notification: The notification object
     */
    @objc
    private func refreshData(notification: Notification) {
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                if weakSelf.selectedIndex != nil {
                    
                    weakSelf.cachedNotesArray.remove(at: weakSelf.selectedIndex!)
                    weakSelf.selectedIndex = nil
                }
            }
        }
    }
    
    /**
     Shows notables fetched from HAT
     
     - parameter array: The fetched notables
     */
    private func showNotables(array: [JSON], renewedUserToken: String?) {
        
        if self.isViewLoaded && (self.view.window != nil) {
            
            DispatchQueue.global().async { [weak self] () -> Void in
                
                if let weakSelf = self {
                    
                    if array.count >= Int(weakSelf.notablesFetchLimit)! {
                        
                        // increase limit
                        weakSelf.notablesFetchLimit = "500"
                        
                        // init object from array
                        let object = HATNotesData(dict: (array.last?.dictionaryValue)!)
                        
                        // set unix date
                        weakSelf.notablesFetchEndDate = HATFormatterHelper.formatDateToEpoch(date: object.lastUpdated)
                        
                        // change parameters
                        weakSelf.parameters = ["starttime": "0",
                                           "endtime": weakSelf.notablesFetchEndDate!,
                                           "limit": weakSelf.notablesFetchLimit]
                        
                        // fetch notes
                        HATNotablesService.fetchNotables(
                            userDomain: weakSelf.userDomain,
                            authToken: weakSelf.userToken,
                            structure: HATJSONHelper.createNotablesTableJSON(),
                            parameters: weakSelf.parameters,
                            success: weakSelf.showNotables,
                            failure: { _ in })
                        
                    } else {
                        
                        // revert parameters to initial values
                        weakSelf.notablesFetchEndDate = nil
                        weakSelf.parameters = ["starttime": "0",
                                           "limit": weakSelf.notablesFetchLimit]
                    }
                    
                    weakSelf.showReceivedNotesFrom(array: array)
                    
                    // refresh user token
                    KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: renewedUserToken)
                }
            }
        }
    }

    // MARK: - Table View Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // get cell from the reusable id
        let controller = NotablesTableViewCell()
        controller.notesDelegate = self
        
        if self.cachedNotesArray[indexPath.row].data.photoData.link != "" {
            
            if let tempCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.cellDataWithImage, for: indexPath) as? NotablesTableViewCell {
                
                return controller.setUpCell(tempCell, note: self.cachedNotesArray[indexPath.row], indexPath: indexPath)
            }
        }
        
        let tempCell = tableView.dequeueReusableCell(withIdentifier: Constants.CellReuseIDs.cellData, for: indexPath) as? NotablesTableViewCell
        return controller.setUpCell(tempCell!, note: self.cachedNotesArray[indexPath.row], indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // return number of notes
        return self.cachedNotesArray.count
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // enable swipe to delete
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCellEditingStyle.delete {
            
            self.selectedIndex = indexPath.row
            
            // if it is shared show message else delete the row
            if self.cachedNotesArray[indexPath.row].data.shared {
                
                self.createClassicAlertWith(
                    alertMessage: "Deleting a note that has already been shared will not delete it at the destination. \n\nTo remove a note from the external site, first make it private. You may then choose to delete it.",
                    alertTitle: "",
                    cancelTitle: "Cancel",
                    proceedTitle: "Proceed",
                    proceedCompletion: { [weak self] in self?.deleteNote(result: nil) },
                    cancelCompletion: {})
            } else {
                
                deleteNote(result: nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if self.cachedNotesArray[indexPath.row].data.photoData.link != "" {
            
            return 235
        }
        
        return 139
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // deselect selected row
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.selectedIndex = indexPath.row
    }
    
    // MARK: - Delete Note
    
    /**
     Deletes a note from HAT
     
     - parameter result: An optional string used for the unauthorisedResponse function
     */
    private func deleteNote(result: String?) {
        
        func success(token: String?) {
            
            KeychainHelper.setKeychainValue(key: token, value: Constants.Keychain.userToken)
            HATNotablesService.deleteNote(
                recordID: self.cachedNotesArray[self.selectedIndex!].noteID,
                tkn: userToken,
                userDomain: userDomain
            )
            
            self.cachedNotesArray.remove(at: selectedIndex!)
            tableView.deleteRows(at: [IndexPath(row: selectedIndex!, section: 0)], with: .fade)
            self.updateUI()
        }
        
        // check token
        self.addChildViewController(NotablesViewController.authoriseVC)
        NotablesViewController.authoriseVC.completionFunc = success(token:)

        NotablesViewController.authoriseVC.checkToken(viewController: self)
    }
    
    // MARK: - Network functions
    
    /**
     Connects to the server to get the notes
     */
    private func connectToServerToGetNotes(result: String?) {
        
        self.showEmptyTableLabelWith(message: "Accessing your HAT...")
        
        self.fetchNotes()
    }
    
    // MARK: - Fetch Notes
    
    /**
     Fetches notes from HAT
     */
    func fetchNotes() {
        
        HATNotablesService.fetchNotables(
            userDomain: userDomain,
            authToken: userToken,
            structure: HATJSONHelper.createNotablesTableJSON(),
            parameters: self.parameters,
            success: self.showNotables,
            failure: {[weak self] error in
                
                switch error {
                    
                case .generalError(_, let statusCode, _) :
                    
                    if statusCode != nil {
                        
                        if statusCode != 404 && statusCode != 401 {
                            
                            self?.showEmptyTableLabelWith(message: "There was an error fetching notes. Please try again later")
                        }
                        self?.connectToServerToGetNotes(result: nil)
                    }
                    
                case .tableDoesNotExist:
                    
                    if self != nil {
                        
                        HATAccountService.createHatTable(
                            userDomain: self!.userDomain,
                            token: self!.userToken,
                            notablesTableStructure: HATJSONHelper.createNotablesTableJSON(),
                            failed: {(createTableError: HATTableError) -> Void in
                                
                                CrashLoggerHelper.hatTableErrorLog(error: createTableError)
                            }
                        )()
                    }
                    
                default:
                    
                    CrashLoggerHelper.hatTableErrorLog(error: error)
                }
            }
        )
    }
    
    // MARK: - Update notes data
    
    func updateNote(_ note: HATNotesData, at index: Int) {
        
        self.cachedNotesArray[index] = note
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.destination is ShareOptionsViewController {
            
            weak var destinationVC = segue.destination as? ShareOptionsViewController

            if segue.identifier == Constants.Segue.editNoteSegue || segue.identifier == Constants.Segue.editNoteSegueWithImage {
                
                if let senderAsCell = sender as? UITableViewCell {
                    
                    let cellIndexPath = self.tableView.indexPath(for: senderAsCell)
                    destinationVC?.receivedNote = self.cachedNotesArray[(cellIndexPath?.row)!]
                    destinationVC?.isEditingExistingNote = true
                    
                    if let cell = self.tableView.cellForRow(at: cellIndexPath!) as? NotablesTableViewCell {
                        
                        if cell.fullSizeImage != nil {
                            
                            destinationVC?.selectedImage = cell.fullSizeImage
                        }
                    }
                }
            } else {
                
                destinationVC?.kind = self.kind
            }
        }
    }
    
    /**
     Hides table and shows a label with the predifined label
     
     - parameter message: The message to show on the label
     */
    private func showEmptyTableLabelWith(message: String) {
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                if weakSelf.cachedNotesArray.isEmpty {
                    
                    var stringMessage = message
                    
                    if stringMessage == "The Internet connection appears to be offline." {
                        
                        weakSelf.retryConnectingButton.isHidden = false
                        stringMessage = "No Internet connection. Please retry"
                    } else {
                        
                        weakSelf.retryConnectingButton.isHidden = true
                    }
                    
                    weakSelf.eptyTableInfoLabel.isHidden = false
                    
                    weakSelf.eptyTableInfoLabel.text = stringMessage
                    
                    weakSelf.tableView.isHidden = true
                }
            }
        }
    }
    
    /**
     Updates the UI elements according the messages received from the HAT
     */
    private func updateUI() {
        
        DispatchQueue.main.async { [weak self] () -> Void in
            
            if let weakSelf = self {
                
                if !weakSelf.notesArray.isEmpty {
                    
                    weakSelf.eptyTableInfoLabel.isHidden = true
                    
                    weakSelf.tableView.isHidden = false
                    
                    var temp = weakSelf.cachedNotesArray
                    
                    for note in weakSelf.notesArray {
                        
                        temp.append(note)
                    }
                    
                    for (index, item) in temp.enumerated() {
                        
                        print("index: \(index) message: \(item.data.message)")
                    }
                    
                    weakSelf.cachedNotesArray.removeAll()
                    
                    temp = HATNotablesService.removeDuplicatesFrom(array: temp)
                    
                    weakSelf.cachedNotesArray = HATNotablesService.sortNotables(notes: temp)
                    
                    weakSelf.notesArray.removeAll()
                    
                    // reload table
                    weakSelf.tableView.reloadData()
                    
                } else if weakSelf.notesArray.isEmpty {
                    
                    weakSelf.showEmptyTableLabelWith(message: "No notables. Keep your words on your HAT. Create your first notable!")
                }
            }
        }
    }
}
