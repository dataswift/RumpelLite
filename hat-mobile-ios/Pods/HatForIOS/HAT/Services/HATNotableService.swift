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

import Alamofire
import SwiftyJSON

// MARK: Struct

/// A class about the methods concerning the Notables service
public struct HATNotablesService {
    
    // MARK: - Get Notes
    
    /**
     Checks if notables table exists
     
     - parameter authToken: The auth token from hat
     */
    public static func fetchNotables(userDomain: String, authToken: String, structure: Dictionary<String, Any>, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON], String?) -> Void, failure: @escaping (HATTableError) -> Void ) {
        
        HATAccountService.checkHatTableExists(
            userDomain: userDomain, tableName: "notablesv1",
            sourceName: "rumpel",
            authToken: authToken,
            successCallback: getNotes(userDomain: userDomain, token: authToken, parameters: parameters, success: success),
            errorCallback: failure)
    }
    
    /**
     Gets the notes of the user from the HAT
     
     - parameter token: The user's token
     - parameter tableID: The table id of the notes
     */
    private static func getNotes(userDomain: String, token: String, parameters: Dictionary<String, String>, success: @escaping (_ array: [JSON], String?) -> Void) -> (_ tableID: NSNumber, _ token: String?) -> Void {
        
        return { (tableID: NSNumber, returnedToken: String?) -> Void in
            
            HATAccountService.getHatTableValues(
                token: token,
                userDomain: userDomain,
                tableID: tableID,
                parameters: parameters,
                successCallback: success,
                errorCallback: { _ in return })
        }
    }
    
    /**
     Gets the notes of the user from the HAT
     
     - parameter token: The user's token
     - parameter tableID: The table id of the notes
     */
    public static func getNotesV2(userDomain: String, token: String, parameters: Dictionary<String, String> = ["orderBy": "updated_time", "ordering": "descending"], success: @escaping (_ array: [HATNotesV2Object], String?) -> Void) {
        
        func gotNotes(notesJSON: [JSON], newToken: String?) {
            
            var notes: [HATNotesV2Object] = []
            
            for item in notesJSON {
                
                if let note = item.dictionary {
                    
                    if let tempNote: HATNotesV2Object = (HATNotesV2Object.decode(from: note)) {
                        
                        notes.append(tempNote)
                    }
                }
            }
            
            success(notes, newToken)
        }
        
        func error(error: HATTableError) {
            
        }
        
        HATAccountService.getHatTableValuesv2(
            token: token,
            userDomain: userDomain,
            namespace: "rumpel",
            scope: "notablesv1",
            parameters: parameters,
            successCallback: gotNotes,
            errorCallback: error)
    }
    
    // MARK: - Delete notes
    
    /**
     Deletes a note from the hat
     
     - parameter id: the id of the note to delete
     - parameter tkn: the user's token as a string
     */
    public static func deleteNote(recordID: Int, tkn: String, userDomain: String, success: @escaping ((String) -> Void) = { _ in }, failed: @escaping ((HATTableError) -> Void) = { _ in }) {
        
        HATAccountService.deleteHatRecord(userDomain: userDomain, token: tkn, recordId: recordID, success: success, failed: failed)
    }
    
    /**
     Deletes a note from the hat
     
     - parameter id: the id of the note to delete
     - parameter tkn: the user's token as a string
     */
    public static func deleteNotesv2(noteIDs: [String], tkn: String, userDomain: String, success: @escaping ((String) -> Void) = { _ in }, failed: @escaping ((HATTableError) -> Void) = { _ in }) {
        
        HATAccountService.deleteHatRecordV2(userDomain: userDomain, token: tkn, recordId: noteIDs, success: success, failed: failed)
    }
    
    // MARK: - Update note
    
    /**
     updates a note from the hat
     
     - parameter id: the id of the note to delete
     - parameter tkn: the user's token as a string
     */
    public static func updateNotev2(note: HATNotesV2Object, tkn: String, userDomain: String, success: @escaping (([JSON], String?) -> Void) = { _, _  in }, failed: @escaping ((HATTableError) -> Void) = { _ in }) {
        
        // update JSON file with the values needed
        let hatData = HATNotesV2DataObject.encode(from: note.data)!
        
        HATAccountService.updateHatRecordV2(
            userDomain: userDomain,
            token: tkn,
            parameters: hatData,
            successCallback: success,
            errorCallback: failed)
    }
    
    // MARK: - Post note
    
    /**
     Posts the note to the hat
     
     - parameter token: The token returned from the hat
     - parameter json: The json file as a Dictionary<String, Any>
     */
    public static func postNote(userDomain: String, userToken: String, note: HATNotesData, successCallBack: @escaping () -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        func posting(resultJSON: Dictionary<String, Any>, token: String?) {
            
            // create the headers
            let headers = ["Accept": ContentType.JSON,
                           "Content-Type": ContentType.JSON,
                           "X-Auth-Token": userToken]
            
            // create JSON file for posting with default values
            let hatDataStructure = HATJSONHelper.createJSONForPosting(hatTableStructure: resultJSON)
            // update JSON file with the values needed
            let hatData = HATJSONHelper.updateNotesJSONFile(file: hatDataStructure, noteFile: note, userDomain: userDomain)
            
            // make async request
            HATNetworkHelper.asynchronousRequest("https://\(userDomain)/data/record/values", method: HTTPMethod.post, encoding: Alamofire.JSONEncoding.default, contentType: ContentType.JSON, parameters: hatData, headers: headers, completion: { (response: HATNetworkHelper.ResultType) -> Void in
                
                // handle result
                switch response {
                    
                case .isSuccess(let isSuccess, _, _, _):
                    
                    if isSuccess {
                        
                        // reload table
                        successCallBack()
                        
                        HATAccountService.triggerHatUpdate(userDomain: userDomain, completion: { () })
                    }
                    
                case .error(let error, let statusCode):
                    
                    if error.localizedDescription == "The request timed out." {
                        
                        errorCallback(.noInternetConnection)
                    } else {
                        
                        let message = NSLocalizedString("Server responded with error", comment: "")
                        errorCallback(.generalError(message, statusCode, error))
                    }
                }
            })
        }
        
        HATAccountService.checkHatTableExistsForUploading(userDomain: userDomain, tableName: "notablesv1", sourceName: "rumpel", authToken: userToken, successCallback: posting, errorCallback: errorCallback)
    }
    
    // MARK: - Post note
    
    /**
     Posts the note to the hat
     
     - parameter token: The token returned from the hat
     - parameter json: The json file as a Dictionary<String, Any>
     */
    public static func postNoteV2(userDomain: String, userToken: String, note: HATNotesV2Object, successCallBack: @escaping (JSON, String?) -> Void, errorCallback: @escaping (HATTableError) -> Void) {
        
        // update JSON file with the values needed
        let hatData = HATNotesV2DataObject.encode(from: note.data)!
        
        HATAccountService.createTableValuev2(
            token: userToken,
            userDomain: userDomain,
            source: "rumpel",
            dataPath: "notablesv1",
            parameters: hatData,
            successCallback: { notes, newToken in
                
                HATAccountService.triggerHatUpdate(userDomain: userDomain, completion: { () })
                successCallBack(notes, newToken)
        },
            errorCallback: errorCallback)
    }
    
    // MARK: - Remove duplicates
    
    /**
     Removes duplicates from an array of NotesData and returns the corresponding objects in an array
     
     - parameter array: The NotesData array
     - returns: An array of NotesData
     */
    public static func removeDuplicatesFrom(array: [HATNotesData]) -> [HATNotesData] {
        
        // the array to return
        var arrayToReturn: [HATNotesData] = []
        
        // go through each note object in the array
        for note in array {
            
            // check if the arrayToReturn it contains that value and if not add it
            let result = arrayToReturn.contains(where: {(note2: HATNotesData) -> Bool in
                
                if (note.data.createdTime == note2.data.createdTime) && (note.data.message == note2.data.message) {
                    
                    if (note.lastUpdated < note2.lastUpdated) || (note.noteID == note2.noteID) {
                        
                        return true
                    }
                }
                
                return false
            })
            
            if !result {
                
                arrayToReturn.append(note)
            }
        }
        
        return arrayToReturn
    }
    
    /**
     Removes duplicates from an array of NotesData and returns the corresponding objects in an array
     
     - parameter array: The NotesData array
     - returns: An array of NotesData
     */
    public static func removeDuplicatesFrom(array: [HATNotesV2Object]) -> [HATNotesV2Object] {
        
        // the array to return
        var arrayToReturn: [HATNotesV2Object] = []
        
        // go through each note object in the array
        for note in array {
            
            // check if the arrayToReturn it contains that value and if not add it
            let result = arrayToReturn.contains(where: {(note2: HATNotesV2Object) -> Bool in
                
                if note.recordId == note2.recordId {
                    
                    return true
                }
                
                return false
            })
            
            if !result {
                
                arrayToReturn.append(note)
            }
        }
        
        return arrayToReturn
    }
    
    // MARK: - Sort notables
    
    /**
     Sorts notes based on updated time
     
     - parameter notes: The NotesData array
     - returns: An array of NotesData
     */
    public static func sortNotables(notes: [HATNotesData]) -> [HATNotesData] {
        
        return notes.sorted { $0.lastUpdated > $1.lastUpdated }
    }
    
    /**
     Sorts notes based on updated time
     
     - parameter notes: The NotesData array
     - returns: An array of NotesData
     */
    public static func sortNotables(notes: [HATNotesV2Object]) -> [HATNotesV2Object] {
        
        return notes.sorted { $0.data.updated_time > $1.data.updated_time }
    }
}
