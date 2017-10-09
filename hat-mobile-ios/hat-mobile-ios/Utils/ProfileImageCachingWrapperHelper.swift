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

internal struct ProfileImageCachingWrapperHelper {

    // MARK: - Network Request
    
    /**
     The request to get the system status from the HAT
     
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     - parameter parameters: A dictionary of type <String, String> specifying the request's parameters
     - parameter failRespond: A completion function of type (HATTableError) -> Void
     
     - returns: A function of type (([HATNotesData], String?) -> Void)
     */
    static func requestProfileObject(userToken: String, userDomain: String, cacheTypeID: String, failRespond: @escaping (HATTableError) -> Void) -> ((@escaping (([ProfileImageObject], String?) -> Void)) -> Void) {
        
        return { successRespond in
            
            func success(json: [JSON], newToken: String?) {
                
                var profileImageObject = ProfileImageObject()

                if !json.isEmpty {
                    
                    if let dict = (json[0].dictionary)?["data"]?.dictionary {
                        
                        profileImageObject = ProfileImageObject(dictionary: dict)
                        if profileImageObject.profileImage != nil {
                            
                            if let url = URL(string: profileImageObject.profileImage!.contentURL) {
                                
                                // download image
                                URLSession.shared.dataTask(with: url) { (data, response, error) in
                                    
                                    guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                                        let mimeType = response?.mimeType, mimeType.hasPrefix("binary"),
                                        let data = data, error == nil,
                                        let image = UIImage(data: data)
                                        else { return }
                                    profileImageObject.profileImage?.image = image
                                    successRespond([profileImageObject], newToken)
                                }.resume()
                            }
                        }
                    }
                }
                
                successRespond([profileImageObject], newToken)
            }
            
            func failed(error: HATTableError) {
                
                failRespond(error)
                CrashLoggerHelper.hatTableErrorLog(error: error)
            }
            
            HATAccountService.getHatTableValuesv2(
                token: userToken,
                userDomain: userDomain,
                namespace: Constants.HATTableName.ProfileImage.source,
                scope: Constants.HATTableName.ProfileImage.name,
                parameters: ["take": "1", "orderBy": "dateUploaded", "ordering": "descending"],
                successCallback: success,
                errorCallback: failed)
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
    static func getProfileObject(userToken: String, userDomain: String, cacheTypeID: String, successRespond: @escaping ([ProfileImageObject], String?) -> Void, failRespond: @escaping (HATTableError) -> Void) {
        
        let profilesToBeSynced = CachingHelper.getFromRealm(type: "profileImage-Post")
        if !profilesToBeSynced.isEmpty {
            
            ProfileImageCachingWrapperHelper.checkForUnsyncedImagesToUpdate(
                userToken: userToken,
                userDomain: userDomain,
                progressUpdater: nil,
                completion: { (_, _) in return },
                errorCallback: failRespond)
        } else {
            
            ProfileImageCachingWrapperHelper.checkForUnsyncedProfileObjectToUpdate(
                userDomain: userDomain,
                userToken: userToken)
        }
        
        ProfileImageCachingWrapperHelper.checkForUnsyncedImagesToDelete(
            userToken: userToken,
            userDomain: userDomain,
            completion: { (_, _) in return },
            errorCallback: { _ in return })
        
        // Decide to get data from cache or network
        AsyncCachingHelper.decider(
            type: cacheTypeID,
            expiresIn: Calendar.Component.day,
            value: 1,
            networkRequest: ProfileImageCachingWrapperHelper.requestProfileObject(userToken: userToken, userDomain: userDomain, cacheTypeID: cacheTypeID, failRespond: failRespond),
            completion: successRespond
        )
    }
    
    // MARK: - Post
    
    /**
     Posts a note
     
     - parameter note: The note to be posted
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     */
    static func postProfileObject(profile: ProfileImageObject, userToken: String, userDomain: String, successCallback: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // remove note from notes
        CachingHelper.deleteFromRealm(type: "profileImageObject")
        CachingHelper.deleteFromRealm(type: "profileImageObject-Post")
        
        // adding note to be posted in cache
        do {
            
            let realm = RealmHelper.getRealm()
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [profile.toJSON()], type: "profileImageObject", expiresIn: .day, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [profile.toJSON()], type: "profileImageObject-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
            }
        } catch {
            
            print("adding to profile to update failed")
        }
        
        ProfileImageCachingWrapperHelper.checkForUnsyncedProfileObjectToUpdate(
            userDomain: userDomain,
            userToken: userToken,
            completion: successCallback,
            errorCallback: errorCallback)
    }
    
    /**
     Checks for unsynced notes to post
     
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     */
    static func checkForUnsyncedProfileObjectToUpdate(userDomain: String, userToken: String, completion: (() -> Void)? = nil, errorCallback: ((HATTableError) -> Void)? = nil) {
        
        // Try deleting the notes
        func tryUpdating(infoArray: [JSONCacheObject]) {
            
            for object in infoArray where object.jsonData != nil {
                
                if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: object.jsonData!) as? [Dictionary<String, Any>] {
                    
                    let profileImageObject = ProfileImageObject(fromCache: dictionary[0])
                    
                    func valueCreated(result: JSON, renewedUserToken: String?) {
                        
                        do {
                            let realm = RealmHelper.getRealm()
                            try realm.write {
                                
                                realm.delete(object)
                            }
                        } catch {
                            
                            print("error deleting from realm")
                        }
                        completion?()
                    }
                    
                    func failed(error: HATTableError) {
                        
                        errorCallback?(error)
                        CrashLoggerHelper.hatTableErrorLog(error: error)
                    }
                    
                    HATAccountService.createTableValuev2(
                        token: userToken,
                        userDomain: userDomain,
                        source: Constants.HATTableName.ProfileImage.source,
                        dataPath: Constants.HATTableName.ProfileImage.name,
                        parameters: profileImageObject.toJSON(),
                        successCallback: valueCreated,
                        errorCallback: failed)
                }
            }
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "profileImageObject-Post", sync: tryUpdating)
    }
    
    /**
     Posts a note
     
     - parameter note: The note to be posted
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     */
    static func tryToUpload(image: UIImage, name: String = "rumpelPhoto", tags: [String] = ["iphone", "viewer", "photo"], userToken: String, userDomain: String, progressUpdater: ((Double) -> Void)?, successCallback: @escaping (FileUploadObject, String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        guard let dataImage = UIImageJPEGRepresentation(image, 1.0) else {
            
            return
        }
        
        // adding note to be posted in cache
        do {
            
            let realm = RealmHelper.getRealm()
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [["image": dataImage]], type: "profileImage", expiresIn: .day, value: 1)
                realm.add(jsonObject)
                
                let jsonObject2 = JSONCacheObject(dictionary: [["image": dataImage]], type: "profileImage-Post", expiresIn: nil, value: nil)
                realm.add(jsonObject2)
            }
        } catch {
            
            print("adding to profile to update failed")
        }
        
        ProfileImageCachingWrapperHelper.checkForUnsyncedImagesToUpdate(
            userToken: userToken,
            userDomain: userDomain,
            name: name,
            tags: tags,
            progressUpdater: progressUpdater,
            completion: successCallback,
            errorCallback: errorCallback)
    }
    
    /**
     Posts a note
     
     - parameter note: The note to be posted
     - parameter userToken: The user's token
     - parameter userDomain: The user's domain
     */
    static func tryToDelete(fileID: String, userToken: String, userDomain: String, successCallback: @escaping (Bool, String?) -> Void, errorCallback: @escaping (HATError) -> Void) {
        
        // adding note to be posted in cache
        do {
            
            let realm = RealmHelper.getRealm()
            
            try realm.write {
                
                let jsonObject = JSONCacheObject(dictionary: [["fileID": fileID]], type: "image-delete", expiresIn: nil, value: nil)
                realm.add(jsonObject)
            }
        } catch {
            
            print("adding to images to be deleted failed")
        }
        
        ProfileImageCachingWrapperHelper.checkForUnsyncedImagesToDelete(
            userToken: userToken,
            userDomain: userDomain,
            completion: successCallback,
            errorCallback: errorCallback)
    }
    
    static func checkForUnsyncedImagesToDelete(userToken: String, userDomain: String, completion: @escaping (Bool, String?) -> Void, errorCallback: ((HATError) -> Void)?) {
        
        // Try deleting the images
        func tryDeleting(infoArray: [JSONCacheObject]) {
            
            for object in infoArray where object.jsonData != nil {
                
                if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: object.jsonData!) as? [Dictionary<String, Any>] {
                    
                    if let tempFileID = dictionary[0]["fileID"] as? String {
                        
                        func deleteFromCache(object: JSONCacheObject) {
                            
                            do {
                                let realm = RealmHelper.getRealm()
                                try realm.write {
                                    
                                    realm.delete(object)
                                }
                            } catch {
                                
                                print("deleting object failed")
                            }
                        }
                        
                        func fileFoundDeleteImage(file: [FileUploadObject], newToken: String?) {
                            
                            HATFileService.deleteFile(
                                fileID: tempFileID,
                                token: userToken,
                                userDomain: userDomain,
                                successCallback: { (success, newToken) in
                                    
                                    deleteFromCache(object: object)
                                    completion(success, newToken)
                                },
                                errorCallBack: { error in
                                    
                                    deleteFromCache(object: object)
                                    completion(false, nil)
                                    errorCallback?(error)
                                }
                            )
                        }
                        
                        HATFileService.searchFiles(
                            userDomain: userDomain,
                            token: userToken,
                            status: "",
                            name: tempFileID,
                            successCallback: fileFoundDeleteImage,
                            errorCallBack: { error in
                                
                                deleteFromCache(object: object)
                                errorCallback?(error)
                            }
                        )
                    }
                }
            }
            
            ProfileImageCachingWrapperHelper.checkForUnsyncedProfileObjectToUpdate(
                userDomain: userDomain,
                userToken: userToken)
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "image-delete", sync: tryDeleting)
    }
    
    static func checkForUnsyncedImagesToUpdate(userToken: String, userDomain: String, name: String = "rumpelPhoto", tags: [String] = ["iphone", "viewer", "photo"], progressUpdater: ((Double) -> Void)?, completion: @escaping (FileUploadObject, String?) -> Void, errorCallback: ((HATTableError) -> Void)?) {
        
        func uploadImage(jsonCacheObject: JSONCacheObject, image: UIImage) {
            
            HATFileService.uploadFileToHATWrapper(
                token: userToken,
                userDomain: userDomain,
                fileToUpload: image,
                tags: tags,
                name: name,
                progressUpdater: { progress in
                    
                    progressUpdater?(progress)
                },
                completion: { (file, newToken) in
                    
                    let realm = RealmHelper.getRealm()

                    let profilesToBeSynced = CachingHelper.getFromRealm(type: "profileImageObject-Post")
                    
                    if !profilesToBeSynced.isEmpty {
                        
                        for profile in profilesToBeSynced where profile.jsonData != nil {
                            
                            if let dict = NSKeyedUnarchiver.unarchiveObject(with: profile.jsonData!) as? [Dictionary<String, Any>] {
                                
                                var profileObject = ProfileImageObject()
                                
                                profileObject.initialize(fromCache: dict[0])
                                
                                for (index, image) in profileObject.selectedImages.enumerated() where image.fileID == file.fileID {
                                    
                                    profileObject.selectedImages.remove(at: index)
                                    profileObject.selectedImages.append(file)
                                }
                                
                                CachingHelper.deleteFromRealm(type: "profileImageObject")
                                CachingHelper.saveToRealm(
                                    dictionary: [profileObject.toJSON()],
                                    objectType: "profileImageObject")
                            }
                        }
                    }
                    
                    do {
                        
                        try realm.write {
                            
                            realm.delete(jsonCacheObject)
                        }
                    } catch {
                        
                        print("deleting object failed")
                    }
                    completion(file, newToken)
                },
                errorCallBack: { error in
                    
                    errorCallback?(error)
                    CrashLoggerHelper.hatTableErrorLog(error: error)
                }
            )
        }
        
        // Try deleting the notes
        func tryUpdating(infoArray: [JSONCacheObject]) {
            
            for object in infoArray where object.jsonData != nil {
                
                if let dictionary = NSKeyedUnarchiver.unarchiveObject(with: object.jsonData!) as? [Dictionary<String, Any>] {
                    
                    if let tempImage = dictionary[0]["image"] as? Data {
                        
                        uploadImage(jsonCacheObject: object, image: UIImage(data: tempImage)!)
                    }
                }
            }
            
            ProfileImageCachingWrapperHelper.checkForUnsyncedProfileObjectToUpdate(
                userDomain: userDomain,
                userToken: userToken)
        }
        
        // ask cache for the notes to be deleted
        CheckCache.searchForUnsyncedCache(type: "profileImage-Post", sync: tryUpdating)
    }
}
