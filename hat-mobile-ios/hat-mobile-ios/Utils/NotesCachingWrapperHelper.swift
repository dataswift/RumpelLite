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
     
     - returns: A function of type (([HATNotesV2Object], String?) -> Void)
     */
    static func request(userToken: String, userDomain: String, parameters: Dictionary<String, String>, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([HATNotesV2Object], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            HATNotablesService.getNotesV2(
                userDomain: userDomain,
                token: userToken,
                parameters: parameters,
                success: successRespond)
        }
    }
    
    // MARK: - Get system status
    
    /**
     Gets the system status from the hat
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter cacheTypeID: The cache type to request
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter successRespond: A completion function of type ([HATNotesV2Object], String?) -> Void
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     */
    static func getNotes(userToken: String, userDomain: String, cacheTypeID: String, parameters: Dictionary<String, String>, successRespond: @escaping ([HATNotesV2Object], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
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
    static func deleteNote(noteID: String, userToken: String, userDomain: String, cacheTypeID: String) {
        
        // remove note from notes
        NotesCachingWrapperHelper.checkForNotesInCacheToBeDeleted(cacheTypeID: "notes", noteID: noteID)

        let dictionary = ["id": noteID]
        
        // adding note to be deleted in cache
        let jsonObject = JSONCacheObject(dictionary: [dictionary], type: cacheTypeID, expiresIn: nil, value: nil)
        
        do {
            
            guard let realm = RealmHelper.getRealm() else {
                
                return
            }

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
    static func postNote(note: HATNotesV2Object, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        NotesCachingWrapperHelper.checkForNotesInCacheToBeDeleted(cacheTypeID: "notes", noteID: note.recordId)
        
        var note = note
        note.data.authorv1.phata = userDomain
        
        let date = Date()
        let dateString = HATFormatterHelper.formatDateToISO(date: date)
        
        note.data.updated_time = dateString
        if note.data.created_time == "" {
            
            note.data.created_time = dateString
        }
        
        // creating note to be posted in cache
        var dictionary = note.data.toJSON()
        if let photo = note.data.photov1 {
            
            if photo.link != "" && photo.link != nil {
                
                guard let url = URL(string: photo.link!) else {
                    
                    return
                }
                
                let imageView = UIImageView()
                imageView.hnk_setImage(
                    from: url,
                    placeholder: UIImage(named: Constants.ImageNames.placeholderImage),
                    headers: ["x-auth-token": userToken],
                    success: { image in
                        
                        guard image != nil else {
                            
                            return
                        }
                        
                        if let imageData = UIImageJPEGRepresentation(image!, 1.0) {
                            
                            dictionary.updateValue(imageData, forKey: "imageData")
                        }
                    },
                    failure: { _ in return },
                    update: { _ in return })
            }
        }
        
        // adding note to be posted in cache
        do {
            
            guard let realm = RealmHelper.getRealm() else {
                
                return
            }

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
    static func checkForNotesInCacheToBeDeleted(cacheTypeID: String, noteID: String) {
        
        // get notes from cache
        guard let notesFromCache = CachingHelper.getFromRealm(type: cacheTypeID) else {
            
            return
        }
        
        // iterate through the results and parse it to HATNotesV2Object. If noteID = ID to be deleted, delete it.
        for element in notesFromCache where element.jsonData != nil {
            
            if var dictionary = NSKeyedUnarchiver.unarchiveObject(with: element.jsonData!) as? [Dictionary<String, Any>] {
                
                let json = JSON(dictionary)
                for (index, item) in json.arrayValue.enumerated() {
                    
                    let tempNote = HATNotesV2Object(dict: item.dictionaryValue)
                    if tempNote.recordId == noteID {
                        
                        dictionary.remove(at: index)
                        
                        do {

                            guard let realm = RealmHelper.getRealm() else {
                                
                                return
                            }

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
                    var note = HATNotesV2Object()
                    note.recordId = dictionary[0]["id"].stringValue
                    
                    HATNotablesService.deleteNotesv2(
                        noteIDs: [note.recordId],
                        tkn: userToken,
                        userDomain: userDomain,
                        success: { _ in
                        
                            do {
                                
                                guard let realm = RealmHelper.getRealm() else {
                                    
                                    return
                                }
                                
                                try realm.write {
                                    
                                    realm.delete(tempNote)
                                }
                            } catch {
                                
                                print("error deleting from cache")
                            }
                        },
                        failed: { error in
                            
                            CrashLoggerHelper.hatTableErrorLog(error: error)
                    })
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
                
                func postNote(_ note: HATNotesV2Object) {
                    
                    HATNotablesService.postNoteV2(
                        userDomain: userDomain,
                        userToken: userToken,
                        note: note,
                        successCallBack: { _, _ in
                            
                            do {
                                
                                guard let realm = RealmHelper.getRealm() else {
                                    
                                    return
                                }
                                
                                try realm.write {
                                    
                                    realm.delete(tempNote)
                                    
                                    guard let resuts = CachingHelper.getFromRealm(type: "notes") else {
                                        
                                        return
                                    }
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
                    var note = HATNotesV2Object()
                    note.data.inititialize(dict: dictionary.arrayValue[0].dictionaryValue)
                    if note.data.photov1?.link == "" {
                        
                        if let data = tempDict[0]["imageData"] as? Data {
                            
                            let imageView = UIImageView()
                            let url = URL(string: note.data.photov1!.link!)
                            imageView.hnk_setImage(from: url)
                            
                            HATFileService.uploadFileToHATWrapper(
                                token: userToken,
                                userDomain: userDomain,
                                fileToUpload: imageView.image!,
                                tags: ["photo", "iPhone", "notes"],
                                progressUpdater: nil,
                                completion: { (file, newToken) in
                                    
                                    KeychainHelper.setKeychainValue(key: Constants.Keychain.userToken, value: newToken)
                                    
                                    PresenterOfShareOptionsViewController.checkFilePublicOrPrivate(
                                        fileUploaded: file,
                                        receivedNote: note,
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
            
            if notes.isEmpty {
                
                completion?()
            }
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "notes-Post", sync: tryPosting)
    }
    
    static func addImageToNote(recordID: String, link: String, userToken: String, image: UIImage? = nil) {
        
        guard let results = CachingHelper.getFromRealm(type: "notes") else {
            
            return
        }
        
        for tempNote in results where tempNote.jsonData != nil {
            
            func saveImage(image: UIImage?, index: Int, dict: [Dictionary<String, Any>]) {
                
                guard let image = image else {
                    
                    return
                }
                
                var dict = dict
                if let imageData = UIImageJPEGRepresentation(image, 1.0) {
                    
                    do {
                        
                        dict[index].updateValue(imageData, forKey: "imageData")
                        
                        guard let realm = RealmHelper.getRealm() else {
                            
                            return
                        }
                        
                        try realm.write {
                            
                            tempNote.jsonData = NSKeyedArchiver.archivedData(withRootObject: dict)
                            realm.add(tempNote)
                        }
                    } catch {
                        
                        print("error updating cache with image")
                    }
                }
            }
            
            if let tempDict = NSKeyedUnarchiver.unarchiveObject(with: tempNote.jsonData!) as? [Dictionary<String, Any>] {
                
                let json = JSON(tempDict)
                var newNote = HATNotesV2Object()
                for (index, dictionary) in json.arrayValue.enumerated() {
                    
                    newNote.inititialize(dict: dictionary.dictionaryValue)
                    
                    if image != nil {
                        
                        saveImage(image: image, index: index, dict: tempDict)
                    } else if newNote.recordId == recordID {
                        
                        let imageView = UIImageView()
                        let url = URL(string: (newNote.data.photov1?.link)!)
                        imageView.hnk_setImage(
                            from: url,
                            placeholder: UIImage(named: Constants.ImageNames.placeholderImage),
                            headers: ["x-auth-token": userToken],
                            success: { image in
                                
                                saveImage(image: image, index: index, dict: tempDict)
                            },
                            failure: nil,
                            update: nil)
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
