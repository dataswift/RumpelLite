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

internal struct ProfileImageObject {
    
    // MARK: - Fields
    
    /// The JSON fields
    private struct Fields {
        
        static let profile: String = "profile"
        static let dateUploaded: String = "dateUploaded"
        static let selectedImages: String = "selectedImages"
    }
    
    // MARK: - Variables

    /// The selected images of the profile
    var selectedImages: [FileUploadObject] = []
    /// The main Profile Image
    var profileImage: FileUploadObject?
    
    /// The uploaded date
    private var dateUploaded: Date = Date()
    
    // MARK: - Initialisers

    /**
     The default initialiser. Initialises everything to default values.
     */
    init() {
        
        selectedImages = []
        profileImage = nil
        dateUploaded = Date()
    }
    
    /**
     It initialises everything from the received JSON file from the HAT
     */
    init(dictionary: Dictionary<String, JSON>) {
        
        if let tempProfileImage = dictionary[Fields.profile]?.dictionary {
            
            profileImage = FileUploadObject(from: tempProfileImage)
        }
        
        if let tempDateUploaded = dictionary[Fields.dateUploaded]?.intValue {
            
            dateUploaded = Date(timeIntervalSince1970: TimeInterval(tempDateUploaded))
        }
        
        if let tempSelectedImages = dictionary[Fields.selectedImages]?.array {
            
            for image in tempSelectedImages {
                
                selectedImages.append(FileUploadObject(from: image.dictionaryValue))
            }
        }
    }
    
    // MARK: - JSON Converter
    
    /**
     Converts struct into a JSON file
     
     - returns: An array of dictionaries of type <String, Any>
     */
    func toJSON() -> Dictionary<String, Any> {
    
        func constructSelectedImagesArray() -> [Dictionary<String, Any>] {
            
            var array: [Dictionary<String, Any>] = []
            for image in selectedImages {
                
                array.append(image.toJSON())
            }
            
            return array
        }
        
        if profileImage == nil || profileImage?.image == UIImage(named: Constants.ImageNames.placeholderImage) {
            
            return [
                Fields.selectedImages: constructSelectedImagesArray(),
                Fields.dateUploaded: Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!] as [String : Any]
        }
        
        return [
            Fields.profile: profileImage!.toJSON(),
            Fields.selectedImages: constructSelectedImagesArray(),
            Fields.dateUploaded: Int(HATFormatterHelper.formatDateToEpoch(date: Date())!)!] as [String : Any]
    }
}
