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

// MARK: Struct

internal struct NotesCachingWrapperHelper {
    
    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func request(userToken: String, userDomain: String, parameters: Dictionary<String, String>, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([HATNotesData], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            // get notes from hat
            HATNotablesService.fetchNotables(
                userDomain: userDomain,
                authToken: userToken,
                structure: HATJSONHelper.createNotablesTableJSON(),
                parameters: parameters,
                success: { (json: [JSON], newToken: String?) in
            
                    var arrayToReturn: [HATNotesData] = []
                    
                    // iterate the returned JSON object, parse it and pass it on to the completion function
                    for item in json {
                        
                        arrayToReturn.append(HATNotesData(dict: item.dictionaryValue))
                    }
                    
                    successRespond(arrayToReturn, newToken)
                },
                failure: failRespond)
        }
    }
    
    // MARK: - Get system status
    
    /**
     Gets the system status from the hat
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter cacheTypeID: The cache type to request
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter successRespond: A completion function of type ([HATNotesData], String?) -> Void
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     */
    static func getNotes(userToken: String, userDomain: String, cacheTypeID: String, parameters: Dictionary<String, String>, successRespond: @escaping ([HATNotesData], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.hour,
            value: 1,
            networkRequest: NotesCachingWrapperHelper.request(
                userToken: userToken,
                userDomain: userDomain,
                parameters: parameters,
                failRespond: failRespond),
            completion: successRespond)
    }
    
    // MARK: - Delete Note
    
    /**
     Deletes note
     
     - parameter noteID: The note's to be deleted ID
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter cacheTypeID: The cache type to request
     */
    static func deleteNote(noteID: Int, userToken: String, userDomain: String, cacheTypeID: String) {
        
        // remove note from notes
        NotesCachingWrapperHelper.checkForNotesInCacheToBeDeleted(cacheTypeID: "notes", noteID: noteID)

        let dictionary = ["id": noteID]
        
        // adding note to be deleted in cache
        let jsonObject = JSONCacheObject(dictionary: [dictionary], type: cacheTypeID, expiresIn: nil, value: nil)
        
        do {
            
            let realm = RealmHelper.getRealm()

            try realm.write {
                
                realm.add(jsonObject)
            }
        } catch {
            
            print("adding note to delete failed")
        }
        
        // check in cache for unsynced deletes
        NotesCachingWrapperHelper.checkForUnsyncedDeletes(userDomain: userDomain, userToken: userToken)
    }
    
    // MARK: - Post Note
    
    /**
     Posts a note
     
     - parameter note: The note to be posted
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     */
    static func postNote(note: HATNotesData, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        NotesCachingWrapperHelper.checkForNotesInCacheToBeDeleted(cacheTypeID: "notes", noteID: note.noteID)
        
        var note = note
        note.data.authorData.phata = userDomain
        
        // creating note to be posted in cache
        var dictionary = note.toJSON()
        if let image = note.data.photoData.image {
            
            if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                
                dictionary.updateValue(imageData, forKey: "imageData")
            }
        }
        
        // adding note to be posted in cache
        do {
            
            let realm = RealmHelper.getRealm()

            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [dictionary], type: "notes", expiresIn: .hour, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [dictionary], type: "notes-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
            }
        } catch {
            
            print("adding to notes to Post failed")
        }
        
        NotesCachingWrapperHelper.checkForUnsyncedNotesToPost(userDomain: userDomain, userToken: userToken, completion: successCallback)
    }
    
    // MARK: - Check cache for unsynced stuff
    
    /**
     Check for notes to be deleted in cache
     
     - parameter cacheTypeID: The cache type to request
     - parameter noteID: The note's to be deleted ID
     */
    static func checkForNotesInCacheToBeDeleted(cacheTypeID: String, noteID: Int) {
        
        // get notes from cache
        let notesFromCache = CachingHelper.getFromRealm(type: cacheTypeID)
        
        // iterate through the results and parse it to HATNotesData. If noteID = ID to be deleted, delete it.
        for element in notesFromCache where element.jsonData != nil {
            
            if var dictionary = NSKeyedUnarchiver.unarchiveObject(with: element.jsonData!) as? [Dictionary<String, Any>] {
                
                let json = JSON(dictionary)
                for (index, item) in json.arrayValue.enumerated() {
                    
                    let tempNote = HATNotesData(dict: item.dictionaryValue)
                    if tempNote.noteID == noteID {
                        
                        dictionary.remove(at: index)
                        
                        do {

                            let realm = RealmHelper.getRealm()

                            try realm.write {

                                realm.delete(element)
                                
                                let jsonObject = JSONCacheObject(dictionary: dictionary, type: "notes", expiresIn: .hour, value: 1)
                                realm.add(jsonObject)
                            }
                        } catch {
                            
                            print("error deleting from cache")
                        }
                    }
                }
            }
        }
    }
    
    /**
     Checks for unsynced deletes
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     */
    static func checkForUnsyncedDeletes(userDomain: String, userToken: String) {
        
        // Try deleting the notes
        func tryDeleting(notes: [JSONCacheObject]) {
            
            // for each note parse it and try to delete it
            for tempNote in notes where tempNote.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                if let tempDict = NSKeyedUnarchiver.unarchiveObject(with: tempNote.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let dictionary = JSON(tempDict)
                    let note = HATNotesData(dict: dictionary.arrayValue[0].dictionary!)
                    
                    HATNotablesService.deleteNote(
                        recordID: note.noteID,
                        tkn: userToken,
                        userDomain: userDomain,
                        success: { _ in
                            
                            do {
                                
                                let realm = RealmHelper.getRealm()
                                
                                try realm.write {
                                    
                                    realm.delete(tempNote)
                                }
                            } catch {
                                
                                print("error deleting from cache")
                            }
                        },
                        failed: { error in
                            
                            CrashLoggerHelper.hatTableErrorLog(error: error)
                        }
                    )
                }
            }
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "notes-Delete", sync: tryDeleting)
    }
    
    /**
     Checks for unsynced notes to post
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     */
    static func checkForUnsyncedNotesToPost(userDomain: String, userToken: String, completion: (() -> Void)? = nil) {
        
        // Try deleting the notes
        func tryPosting(notes: [JSONCacheObject]) {
            
            // for each note parse it and try to delete it
            for tempNote in notes where tempNote.jsonData != nil && Reachability.isConnectedToNetwork() {
                
                func postNote(_ note: HATNotesData) {
                    
                    HATNotablesService.postNote(
                        userDomain: userDomain,
                        userToken: userToken,
                        note: note,
                        successCallBack: {
                    
                            do {
                                
                                let realm = RealmHelper.getRealm()
                                
                                try realm.write {
                                    
                                    realm.delete(tempNote)
                                    
                                    let resuts = CachingHelper.getFromRealm(type: "notes")
                                    realm.delete(resuts)
                                }
                            } catch {
                                
                                print("error deleting from cache")
                            }
                            
                            completion?()
                        },
                        errorCallback: { error in
                            
                            completion?()
                            CrashLoggerHelper.hatTableErrorLog(error: error)
                        }
                    )
                }
                
                if let tempDict = NSKeyedUnarchiver.unarchiveObject(with: tempNote.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let dictionary = JSON(tempDict)
                    var note = HATNotesData()
                    note.inititialize(dict: dictionary.arrayValue[0].dictionaryValue)
                    if note.data.photoData.link == "" {
                        
                        if let data = tempDict[0]["imageData"] as? Data {
                            
                            note.data.photoData.image = UIImage(data: data)
                            
                            HATFileService.uploadFileToHATWrapper(
                                token: userToken,
                                userDomain: userDomain,
                                fileToUpload: note.data.photoData.image!,
                                tags: ["photo", "iPhone", "notes"],
                                progressUpdater: nil,
                                completion: { (file, newToken) in
                                    
                                    KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: newToken)
                                    
                                    PresenterOfShareOptionsViewController.checkFilePublicOrPrivate(
                                        fileUploaded: file,
                                        receivedNote: &note,
                                        viewController: nil,
                                        success: {
                                            
                                            postNote(note)
                                        }
                                    )
                                },
                                errorCallBack: nil
                            )
                        } else {
                            
                            postNote(note)
                        }
                    } else {
                        
                        postNote(note)
                    }
                }
            }
            
            completion?()
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "notes-Post", sync: tryPosting)
    }
    
    static func addImageToNote(note: HATNotesData) {
        
        let results = CachingHelper.getFromRealm(type: "notes")
        
        for tempNote in results where tempNote.jsonData != nil {
            
            if var tempDict = NSKeyedUnarchiver.unarchiveObject(with: tempNote.jsonData!) as? [Dictionary<String, Any>] {
                
                let json = JSON(tempDict)
                var newNote = HATNotesData()
                for (index, dictionary) in json.arrayValue.enumerated() {
                    
                    newNote.inititialize(dict: dictionary.dictionaryValue)
                    
                    if newNote.noteID == note.noteID && note.data.photoData.image != nil {
                        
                        if let imageData = UIImageJPEGRepresentation(note.data.photoData.image!, 1.0) {
                            
                            do {
                                
                                tempDict[index].updateValue(imageData, forKey: "imageData")
                                let realm = RealmHelper.getRealm()
                                try realm.write {
                                    
                                    tempNote.jsonData = NSKeyedArchiver.archivedData(withRootObject: tempDict)
                                    realm.add(tempNote)
                                }
                            } catch {
                                
                                print("error updating cache with image")
                            }
                        }
                    }
                }
            }
        }
    }

    /**
     Checks for unsynced cache
 
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     */
    static func checkForUnsyncedCache(userDomain: String, userToken: String) {
        
        // if user is connected to the internet try to sync cache
        if Reachability.isConnectedToNetwork() {
            
            NotesCachingWrapperHelper.checkForUnsyncedDeletes(userDomain: userDomain, userToken: userToken)
            NotesCachingWrapperHelper.checkForUnsyncedNotesToPost(userDomain: userDomain, userToken: userToken)
        }
    }
}
