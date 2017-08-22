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

import UIKit

// MARK: Class

// A class handling all the constant values for easy access
internal class Constants {
    
    // MARK: - Typealiases
    
    typealias MarketAccessTokenAlias = String
    typealias MarketDataPlugIDAlias = String
    typealias HATUsernameAlias = String
    typealias HATPasswordAlias = String
    typealias UserHATDomainAlias = String
    typealias HATRegistrationURLAlias = String
    typealias UserHATAccessTokenURLAlias = String
    typealias UserHATDomainPublicTokenURLAlias = String
    
    // MARK: - Enums
    
    /**
     The request fields for data points
     
     - latitude: latitude
     - longitude: longitude
     - accuracy: accuracy
     - timestamp: timestamp
     - allValues: An array of all the above values
     */
    enum RequestFields: String {
        
        case latitude
        case longitude
        case accuracy
        case timestamp
        
        static let allValues: [RequestFields] = [latitude, longitude, accuracy, timestamp]
    }
    
    // MARK: - Structs
    
    /**
     The possible notification names, stored for convenience in one place
     
     - reauthorised: reauthorisedUser
     - dataPlug: dataPlugMessage
     - hideGetAHATPopUp: hideView
     - hatProviders: hatProviders
     - hideInfoHATProvider: hideInfoHATProvider
     - enablePageControll: enablePageControll
     - disablePageControll: disablePageControll
     - hideCapabilitiesPageViewContoller: hideCapabilitiesPageViewContoller
     - hideLearnMore: HideLearnMore
     - hideDataServicesInfo: hideDataServicesInfo
     - networkMessage: NetworkMessage
     - goToSettings: goToSettings
     - reloadTable: reloadTable
     */
    struct NotificationNames {
        
        static let reauthorised: String = "reauthorisedUser"
        static let dataPlug: String = "dataPlugMessage"
        static let hideGetAHATPopUp: String = "hideView"
        static let hatProviders: String = "hatProviders"
        static let hideInfoHATProvider: String = "hideInfoHATProvider"
        static let enablePageControll: String = "enablePageControll"
        static let disablePageControll: String = "disablePageControll"
        static let hideCapabilitiesPageViewContoller: String = "hideCapabilitiesPageViewContoller"
        static let hideLearnMore: String = "HideLearnMore"
        static let hideDataServicesInfo: String = "hideDataServicesInfo"
        static let networkMessage: String = "NetworkMessage"
        static let goToSettings: String = "goToSettings"
        static let reloadTable: String = "reloadTable"
        static let imagePopUp: String = "imagePopUp"
    }
    
    /**
     The possible font names, stored for convenience in one place
     
     - openSansCondensedLight: OpenSans-CondensedLight
     - openSans: OpenSans
     - openSansBold: OpenSans-Bold
     - ssGlyphishFilled: SSGlyphish-Filled
     */
    struct FontNames {
        
        static let openSansCondensedLight: String = "OpenSans-CondensedLight"
        static let openSans: String = "OpenSans"
        static let openSansBold: String = "OpenSans-Bold"
        static let ssGlyphishFilled: String = "SSGlyphish-Filled"
    }
    
    /**
     The possible reuse identifiers of the cells
     
     - dataplug: dataPlugCell
     - onboardingTile: onboardingTile
     - homeHeader: homeHeader
     - socialCell: socialCell
     - offerCell: offerCell
     - summaryOfferCell: summaryOfferCell
     - dataStoreCell: DataStoreCell
     - dataStoreInfoCell: dataStoreInfoCell
     - nameCell: nameCell
     - dataStoreNameCell: dataStoreNameCell
     - profileInfoCell: profileInfoCell
     - dataStoreNationalityCell: dataStoreNationalityCell
     - dataStoreRelationshipCell: dataStoreRelationshipCell
     - dataStoreEducationCell: dataStoreEducationCell
     - dataStoreContactInfoCell: dataStoreContactInfoCell
     - homeScreenCell: homeScreenCell
     - cellDataWithImage: cellDataWithImage
     - cellData: cellData
     - addedImageCell: addedImageCell
     - photosCell: photosCell
     - imageSocialFeedCell: imageSocialFeedCell
     - statusSocialFeedCell: statusSocialFeedCell
     - aboutCell: aboutCell
     - addressCell: addressCell
     - emailCell: emailCell
     - emergencyContactCell: emergencyContactCell
     - optionsCell: optionsCell
     - phataSettingsCell: phataSettingsCell
     - phataCell: phataCell
     - phoneCell: phoneCell
     - resetPasswordCell: resetPasswordCell
     - socialLinksCell: socialLinksCell
     */
    struct CellReuseIDs {
        
        static let dataplug: String = "dataPlugCell"
        static let priorities: String = "prioritiesCell"
        static let interests: String = "interestsCell"
        static let onboardingTile: String = "onboardingTile"
        static let homeHeader: String = "homeHeader"
        static let socialCell: String = "socialCell"
        static let offerCell: String = "offerCell"
        static let summaryOfferCell: String = "summaryOfferCell"
        static let dataStoreCell: String = "DataStoreCell"
        static let dataStoreInfoCell: String = "dataStoreInfoCell"
        static let nameCell: String = "nameCell"
        static let dataStoreNameCell: String = "dataStoreNameCell"
        static let profileInfoCell: String = "profileInfoCell"
        static let dataStoreEmploymentCell: String = "dataStoreEmploymentCell"
        static let dataStoreRelationshipCell: String = "dataStoreRelationshipCell"
        static let dataStoreEducationCell: String = "dataStoreEducationCell"
        static let dataStoreContactInfoCell: String = "dataStoreContactInfoCell"
        static let homeScreenCell: String = "homeScreenCell"
        static let notificationsCell: String = "notificationsCell"
        static let cellDataWithImage: String = "cellDataWithImage"
        static let cellData: String = "cellData"
        static let addedImageCell: String = "addedImageCell"
        static let photosCell: String = "photosCell"
        static let imageSocialFeedCell: String = "imageSocialFeedCell"
        static let statusSocialFeedCell: String = "statusSocialFeedCell"
        static let aboutCell: String = "aboutCell"
        static let addressCell: String = "addressCell"
        static let emailCell: String = "emailCell"
        static let emergencyContactCell: String = "emergencyContactCell"
        static let optionsCell: String = "optionsCell"
        static let phataSettingsCell: String = "phataSettingsCell"
        static let phataCell: String = "phataCell"
        static let phoneCell: String = "phoneCell"
        static let resetPasswordCell: String = "resetPasswordCell"
        static let socialLinksCell: String = "socialLinksCell"
        static let dataStoreUKSpecificInfoCell: String = "dataStoreUKSpecificInfoCell"
        static let forDataOffersCell: String = "forDataOffersCell"
        static let dietaryHabitsCell: String = "dietaryHabitsCell"
        static let physicalActivitiesCell: String = "physicalActivitiesCell"
        static let lifestyleHabitsCell: String = "lifestyleHabitsCell"
        static let financialManagementCell: String = "financialManagementCell"
        static let dataDebitCell: String = "dataDebitCell"
        static let listDataOffersCell: String = "listDataOffersCell"
        static let happinesAndMentalHealthCell: String = "happinesAndMentalHealthCell"
        static let interestsCell: String = "interestsCell"
        static let plugDetailsCell: String = "PlugDetailsCell"
    }
    
    struct TermsURL {
        
        static let rumpel: String = "https://s3-eu-west-1.amazonaws.com/developers.hubofallthings.com/legals/RumpelLite-Terms-of-Service.md"
        static let hat: String = "https://s3-eu-west-1.amazonaws.com/developers.hubofallthings.com/legals/HAT-Terms-of-Service.md"
    }
    
    /**
     The possible table names on HAT
     
     - Profile: Profile struct
     - Location: Location struct
     */
    struct HATTableName {
        
        /**
         The Profile table
         
         - name: profile, the name of the table
         - source: rumpel, the source of the table
         */
        struct Profile {
            
            static let name: String = "profile"
            static let source: String = "rumpel"
        }
        
        /**
         The Location table
         
         - name: locations, the name of the table
         - source: iphone, the source of the table
         */
        struct Location {
            
            static let name: String = "locations"
            static let source: String = "iphone"
        }
        
        /**
         The Profile Image table
         
         - name: profileimage, the name of the table
         - source: rumpel, the source of the table
         */
        struct ProfileImage {
            
            static let name: String = "profileimage"
            static let source: String = "rumpel"
        }
        
        /**
         The UK Specific info profile table
         
         - name: profile/ukSpecificInfo, the name of the table
         - source: rumpel, the source of the table
         */
        struct UKSpecificInfo {
            
            static let name: String = "profile/ukspecificinfo"
            static let source: String = "rumpel"
        }
        
        /**
         The profile info table
         
         - name: profile/profileinfo, the name of the table
         - source: rumpel, the source of the table
         */
        struct ProfileInfo {
            
            static let name: String = "profile/profileinfo"
            static let source: String = "rumpel"
        }
        
        /**
         The employment status profile table
         
         - name: profile/employmentStatus, the name of the table
         - source: rumpel, the source of the table
         */
        struct EmploymentStatus {
            
            static let name: String = "profile/employmentstatus"
            static let source: String = "rumpel"
        }
        
        /**
         The living info profile table
         
         - name: profile/employmentStatus, the name of the table
         - source: rumpel, the source of the table
         */
        struct LivingInfo {
            
            static let name: String = "profile/livinginfo"
            static let source: String = "rumpel"
        }
        
        /**
         The facebook profile table
         
         - name: profile, the name of the table
         - source: facebook, the source of the table
         */
        struct FacebookProfile {
            
            static let name: String = "profile"
            static let source: String = "facebook"
        }
        
        /**
         The dietary priorities of the user
         
         - name: priorities/dietary, the name of the table
         - source: rumpel, the source of the table
         */
        struct DietaryAnswers {
            
            static let name: String = "priorities/dietary"
            static let source: String = "rumpel"
        }
        
        /**
         The physical activities priorities of the user
         
         - name: priorities/physicalactivities, the name of the table
         - source: rumpel, the source of the table
         */
        struct PhysicalActivityAnswers {
            
            static let name: String = "priorities/physicalactivities"
            static let source: String = "rumpel"
        }
        
        /**
         The lifestyle habits priorities of the user
         
         - name: priorities/lifestyle, the name of the table
         - source: rumpel, the source of the table
         */
        struct LifestyleHabitsAnswers {
            
            static let name: String = "priorities/lifestyle"
            static let source: String = "rumpel"
        }
        
        /**
         The happiness and mental health priorities of the user
         
         - name: priorities/happinessandmentalhealth, the name of the table
         - source: rumpel, the source of the table
         */
        struct HappinessAndMentalHealthAnswers {
            
            static let name: String = "priorities/happinessandmentalhealth"
            static let source: String = "rumpel"
        }
        
        /**
         The financial management priorities of the user
         
         - name: priorities/financialmanagement, the name of the table
         - source: rumpel, the source of the table
         */
        struct FinancialManagementAnswers {
            
            static let name: String = "priorities/financialmanagement"
            static let source: String = "rumpel"
        }
        
        /**
         The interests priorities of the user
         
         - name: interests, the name of the table
         - source: rumpel, the source of the table
         */
        struct Interests {
            
            static let name: String = "interests"
            static let source: String = "rumpel"
        }
    }
    
    /**
     Date formats
     
     - utc: the utc representation format (yyyy-MM-dd'T'HH:mm:ssZ)
     - gmt: the gmt representation format (yyyy-MM-dd'T'HH:mm:ssZZZZZ)
     - posix: the posix representation format (yyyy-MM-dd'T'HH:mm:ss.SSSZ)
     - alternative: an alternative representation used when else fails (E MMM dd HH:mm:ss Z yyyy)
     */
    struct DateFormats {
        
        static let utc: String = "yyyy-MM-dd'T'HH:mm:ssZ"
        static let gmt: String = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        static let posix: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        static let alternative: String = "E MMM dd HH:mm:ss Z yyyy"
    }
    
    /**
     Time zone formats
     
     - utc: the UTC representation format
     - gmt: the GMT representation format
     - posix: the en_US_POSIX representation format
     */
    struct TimeZone {
        
        static let utc: String = "UTC"
        static let gmt: String = "GMT"
        static let posix: String = "en_US_POSIX"
    }
    
    /**
     DataPoint Block size
     
     - maxBlockSize: Max block size
     */
    struct DataPointBlockSize {
        
        static let maxBlockSize: Int = 100
    }
    
    /**
     DataPoint purge data
     
     - olderThan: Representing days, 7
     */
    struct PurgeData {
        
        static let olderThan: Double = 7
    }
    
    /**
     Authentication struct
     
     - urlScheme: The name of the declared in the bundle identifier (rumpellocationtrackerapp)
     - serviceName: The name of the service (RumpelLite)
     - localAuthHost: The name of the local authentication host, can be anything (rumpellocationtrackerapphost)
     - notificationHandlerName: The notification handler name, can be anything (rumpellocationtrackerappnotificationhandler)
     - tokenParamName: The token name, QS parameter (token)
     */
    struct Auth {
        
        static let urlScheme: String = "rumpellocationtrackerapp"
        static let serviceName: String = "RumpelLite"
        static let localAuthHost: String = "rumpellocationtrackerapphost"
        static let notificationHandlerName: String = "rumpellocationtrackerappnotificationhandler"
        static let tokenParamName: String = "token"
    }
    
    /**
     Keychain struct
     
     - Values: A struct holding the possible keychain values
     - hatDomainKey: The key used: user_hat_domain
     - trackDeviceKey: The key used: trackDevice
     - userToken: The key used: UserToken
     - logedIn: The key used: logedIn
     */
    struct Keychain {
        
        /**
         Keychain struct
         
         - setTrue: The key used: true
         - setFalse: The key used: false
         - expired: The key used: expired
         */
        struct Values {
            
            static let setTrue: String = "true"
            static let setFalse: String = "false"
            static let expired: String = "expired"
        }
        
        static let hatDomainKey: String = "user_hat_domain"
        static let trackDeviceKey: String = "trackDevice"
        static let userToken: String = "UserToken"
        static let logedIn: String = "logedIn"
        static let newUser: String = "newUser"
    }
    
    /**
     The content types available
     
     - json: application/json
     - text: text/plain
     */
    struct ContentType {
        
        static let json: String = "application/json"
        static let text: String = "text/plain"
    }
    
    /**
     The headers available
     
     - accept: Accept
     - contentType: Content-Type
     - authToken: X-Auth-Token
     */
    struct Headers {
        
        static let accept: String = "Accept"
        static let contentType: String = "Content-Type"
        static let authToken: String = "X-Auth-Token"
    }
    
    /**
     The content types available
     
     - dashedLine: Key: DashedTopLine
     - line: Key: line
     - line2: Key: line2
     */
    struct UIViewLayerNames {
        
        static let dashedLine: String = "DashedTopLine"
        static let line: String = "Line"
        static let line2: String = "Line2"
    }
     
    /**
     HAT credintials for location tracking
     
     - dashedLine: hat username used for location data plug, location
     - hatPassword: hat password used for location data plug, MYl06ati0n
     - marketsquareDataPlugID: market data plug id used for location data plug, c532e122-db4a-44b8-9eaf-18989f214262
     - marketsquareAccessToken: market access token used for location data plug
     */
    struct HATDataPlugCredentials {
        
        //static let hatUsername: String = "location"
        //static let hatPassword: String = "MYl06ati0n"
        static let marketsquareDataPlugID: String = "c532e122-db4a-44b8-9eaf-18989f214262"
        static let marketsquareAccessToken: MarketAccessTokenAlias = "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxLVZyaHVrWFh1bm9LRVwvd3p2Vmh4bm5FakdxVHc2RCs3WVZoMnBLYTdIRjJXbHdUV29MQWR3K0tEdzZrTCtkQjI2eHdEbE5sdERqTmRtRlwvVWtWM1A2ODF3TXBPSUxZbFVPaHI1WnErTT0iLCJkYXRhcGx1ZyI6ImM1MzJlMTIyLWRiNGEtNDRiOC05ZWFmLTE4OTg5ZjIxNDI2MiIsImlzcyI6ImhhdC1tYXJrZXQiLCJleHAiOjE1MTU2MDQ3NzUsImlhdCI6MTQ4NDg0NjM3NSwianRpIjoiZTBlMjIwY2VmNTMwMjllZmQ3ZDFkZWQxOTQzYzdlZWE5NWVjNWEwNGI4ZjA1MjU1MzEwNDgzYTk1N2VmYTQzZWZiMzQ5MGRhZThmMTY0M2ViOGNhNGVlOGZkNzI3ZDBiZDBhZGQyZTgzZWZkNmY4NjM2NWJiMjllYjY2NzQ3MWVhMjgwMmQ4ZTdkZWIxMzlhZDUzY2UwYzQ1ZTgxZmVmMGVjZTI5NWRkNTU0N2I2ODQzZmRiZTZlNjJmZTU1YzczYzAyYjA4MDAzM2FlMzQyMWUxZWJlMGFhOTgzNmE4MGNjZjQ0YmIxY2E1NmQ0ZjM4NWJkMzg1ZDY4ZmY0ZTIwMyJ9.bPTryrVhFa2uAMSZ6A5-Vvca7muEf8RrWoiire7K7ko"
    }
        
    /**
     The user's preferences, settings
     
     - userNewDefaultAccuracy: User's new default accuracy
     - userDefaultAccuracy: User's old default accuracy
     - mapLocationAccuracy: User's map accuracy
     - mapLocationDistance: User's map distance
     - mapLocationDeferredDistance: User's map deferred distance
     - mapLocationDeferredTimeout: User's map deferred timeout
     - successfulSyncCount: Successful sync count
     - successfulSyncDate: Successful sync date
     */
    struct Preferences {

        static let userNewDefaultAccuracy: String = "shared_user_new_default_accuracy"
        static let userDefaultAccuracy: String = "UserNewDefaultAccuracy"
        static let mapLocationAccuracy: String = "shared_map_location_accuracy"
        static let mapLocationDistance: String = "shared_map_location_distance"
        static let mapLocationDeferredDistance: String = "shared_map_location_deferred_distance"
        static let mapLocationDeferredTimeout: String = "shared_map_location_deferred_timeout"
        
        static let successfulSyncCount: String = "shared_successful_sync_count"
        static let successfulSyncDate: String = "shared_successful_sync_date"
    }
    
    /**
     The HAT datasource will never change (not for v1 at least). It's the structure for the data held at HAT
     */
     struct HATDataSource {
        
        /// The name of the data source
        let name: String = "locations"
        /// The source of the data source
        let source: String = "iphone"
        /// The fields of the data source
        var fields: [JSONDataSourceRequestField] = [JSONDataSourceRequestField]()

        /**
         Initializer, for each field in RequestFields.allValues extracts the info and adds it to fields
         */
        init() {

            // iterate over our RequestFields enum
            for field in RequestFields.allValues {
                
                let f: JSONDataSourceRequestField = JSONDataSourceRequestField()
                
                f.name = field.rawValue
                f.fieldEnum = field
                
                fields.append(f)
            }
        }
        
        /**
         Turns the fields into a JSON object, dictionary
         
         - returns: A dictionary of <String, AnyObject>
         */
        func toJSON() -> Dictionary<String, AnyObject> {
            
            var dictionaries = [[String: String]]()

            for field: JSONDataSourceRequestField in self.fields {
                
                dictionaries.append(["name": field.name])
            }

            // return the json as dictionary
            return [
                "name": self.name as AnyObject,
                "source": self.source as AnyObject,
                "fields": dictionaries as AnyObject
            ]
        }
    }
    
    // MARK: - Image names
    
    struct ImageNames {
        
        static let placeholderImage: String = "Image Placeholder"
        static let twitterImage: String = "Twitter"
        static let facebookImage: String = "Facebook"
        static let marketsquareImage: String = "Marketsquare"
        static let gpsFilledImage: String = "gps filled"
        static let imageDeleted: String = "Image Deleted"
        static let notesImage: String = "notes"
        static let gpsOutlinedImage: String = "gps outlined"
        static let socialFeedImage: String = "SocialFeed"
        static let photoViewerImage: String = "Photo Viewer"
        static let profileImage: String = "Profile"
        static let dataStoreImage: String = "Data store"
        static let individualImage: String = "Individual"
        static let secureImage: String = "Secure"
        static let portableImage: String = "Portable"
        static let futureImage: String = "Future"
        static let researchImage: String = "Research"
        static let standsForImage: String = "Stands for"
        static let stuffYourHATImage: String = "Stuff your HAT"
        static let hatServiceImage: String = "HAT Service"
        static let monetizeImage: String = "Monetize"
        static let personaliseImage: String = "Personalize"
        static let getSmartImage: String = "Get Smart"
        static let rumpelImage: String = "Rumpel"
        static let tealBinaryImage: String = "TealBinary"
        static let tealFingerprintImage: String = "TealFingerprint"
        static let tealDevicesImage: String = "TealDevices"
        static let tealImage: String = "Teal Image"
        static let addLocation: String = "Add Location"
        static let cashOffersImage: String = "Cash Offers"
        static let serviceOffersImage: String = "Service Offers"
        static let voucherOffersImage: String = "Voucher Offers"
        static let bemoji: String = "bemoji"
        static let callingCard: String = "callingCard"
        static let doImage: String = "do"
        static let gimme: String = "gimme"
        static let match: String = "match"
        static let read: String = "read"
        static let recall: String = "recall"
        static let socialMediaControl: String = "socialMediaControl"
        static let watch: String = "watch"
        static let cirle: String = "Circle"
        static let circleFilled: String = "Full Circle"
        static let sso: String = "SSO"
        static let goDeep: String = "goDeep"
        static let community: String = "Community"
        static let news: String = "News"
        static let hatLogo: String = "HAT App Logo"
        static let featured: String = "Featured"
        static let savy: String = "Savy"
        static let shapeInfluence: String = "ShapeInfluence"
        static let podsense: String = "Podsense"
        static let hospify: String = "Hospify"
        static let hatters: String = "Hatters"
        static let ideas: String = "Ideas"
        static let profile: String = "Profile"
        static let profileOutline: String = "Profile Outline"
        static let hattersOutline: String = "Hatters Outline"
        static let imagePopUp1: String = "Image-1"
        static let imagePopUp2: String = "Image-2"
        static let imagePopUp3: String = "Image-3"
        static let imagePopUp4: String = "Image-4"
    }
    
    // MARK: - Data Plug
    
    struct DataPlug {
        
        static let offerID: String = "32dde42f-5df9-4841-8257-5639db222e41"
        
        static func twitterDataPlugServiceURL(userDomain: String, socialServiceURL: String) -> String {
            
            return "https://\(userDomain)/hatlogin?name=Twitter&redirect=\(socialServiceURL)/authenticate/hat"
        }
        
        static func facebookDataPlugServiceURL(userDomain: String, socialServiceURL: String) -> String {
            
            return "https://\(userDomain)/hatlogin?name=Facebook&redirect=\(socialServiceURL.replacingOccurrences(of: "dataplug", with: "hat/authenticate"))"
        }
    }
    
    // MARK: - Social networks
    
    struct SocialNetworks {
        
        struct Facebook {
            
            static let name: String = "facebook"
        }
        
        struct Twitter {
            
            static let name: String = "twitter"
        }
    }
    
    // MARK: - Application Tokens
    
    struct ApplicationToken {
        
        struct Dex {
            
            static let name: String = "dex"
            static let source: String = "https://dex.hubofallthings.com"
        }
        
        struct Marketsquare {
            
            static let name: String = "MarketSquare"
            static let source: String = "https://marketsquare.hubofallthings.com"
        }
        
        struct Rumpel {
            
            static let name: String = "Rumpel"
            static let source: String = "https://rumpel.hubofallthings.com"
        }
        
        struct Facebook {
            
            static let name: String = "Facebook"
            static let source: String = "https://social-plug.hubofallthings.com"
        }
        
        struct DataBuyer {
            
            static let name: String = "DataBuyer"
            static let source: String = "https://databuyer.hubofallthings.com/"
        }
    }
    
    // MARK: - Segue
    
    struct Segue {
        
        static let stripeSegue: String = "stripeSegue"
        static let prioritiesSegue: String = "prioritiesSegue"
        static let interestsSegue: String = "interestsSegue"
        static let termsSegue: String = "termsSegue"
        static let completePurchaseSegue: String = "completePurchaseSegue"
        static let offerToOfferDetailsSegue: String = "offerToOfferDetailsSegue"
        static let dataStoreToName: String = "dataStoreToName"
        static let dataStoreToInfoSegue: String = "dataStoreToInfoSegue"
        static let dataStoreToContactInfoSegue: String = "dataStoreToContactInfoSegue"
        static let dataStoreToNationalitySegue: String = "dataStoreToNationalitySegue"
        static let dataStoreToHouseholdSegue: String = "dataStoreToHouseholdSegue"
        static let dataStoreToEducationSegue: String = "dataStoreToEducationSegue"
        static let notesSegue: String = "notesSegue"
        static let locationsSegue: String = "locationsSegue"
        static let socialDataSegue: String = "socialDataSegue"
        static let photoViewerSegue: String = "photoViewerSegue"
        static let settingsSequeID: String = "SettingsSequeID"
        static let optionsSegue: String = "optionsSegue"
        static let editNoteSegue: String = "editNoteSegue"
        static let editNoteSegueWithImage: String = "editNoteSegueWithImage"
        static let checkInSegue: String = "checkInSegue"
        static let goToFullScreenSegue: String = "goToFullScreenSegue"
        static let createNoteToHATPhotosSegue: String = "createNoteToHATPhotosSegue"
        static let fullScreenPhotoViewerSegue: String = "fullScreenPhotoViewerSegue"
        static let phataSegue: String = "phataSegue"
        static let notificationDetailsSegue: String = "notificationsToNotificationDetailsSegue"
        static let notificationsSegue: String = "moreToNotificationsSegue"
        static let moreToResetPasswordSegue: String = "moreToResetPasswordSegue"
        static let dataSegue: String = "dataSegue"
        static let locationsSettingsSegue: String = "locationsSettingsSegue"
        static let moreToTermsSegue: String = "moreToTermsSegue"
        static let profilePhotoToFullScreenPhotoSegue: String = "profilePhotoToFullScreenPhotoSegue"
        static let profilePictureCell: String = "profilePictureCell"
        static let profileImageHeader: String = "profileImageHeader"
        static let profileToHATPhotosSegue: String = "profileToHATPhotosSegue"
        static let phataSettingsSegue: String = "phataSettingsSegue"
        static let phataToEmailSegue: String = "phataToEmailSegue"
        static let phataToPhoneSegue: String = "phataToPhoneSegue"
        static let phataToAddressSegue: String = "phataToAddressSegue"
        static let phataToNameSegue: String = "phataToNameSegue"
        static let phataToProfilePictureSegue: String = "phataToProfilePictureSegue"
        static let phataToEmergencyContactSegue: String = "phataToEmergencyContactSegue"
        static let phataToAboutSegue: String = "phataToAboutSegue"
        static let phataToSocialLinksSegue: String = "phataToSocialLinksSegue"
        static let phataToProfileInfoSegue: String = "phataToProfileInfoSegue"
        static let dataStoreToForDataOffersInfoSegue: String = "dataStoreToForDataOffersInfoSegue"
        static let dataStoreToUKSpecificSegue: String = "dataStoreToUKSpecificSegue"
        static let dataStoreToEmploymentStatusSegue: String = "dataStoreToEmploymentStatusSegue"
        static let dietaryHabitsSegue: String = "dietaryHabitsSegue"
        static let homeToEditNoteSegue: String = "homeToEditNoteSegue"
        static let homeToDataStore: String = "homeToDataStore"
        static let homeToDataPlugs: String = "homeToDataPlugs"
        static let homeToDataOffers: String = "homeToDataOffers"
        static let homeToGoDeepSegue: String = "homeToGoDeepSegue"
        static let homeToForDataOffersSettingsSegue: String = "homeToForDataOffersSettingsSegue"
        static let prioritiesToPhysicalActivitiesSegue: String = "prioritiesToPhysicalActivitiesSegue"
        static let prioritiesToLifestyleHabitsSegue: String = "prioritiesToLifestyleHabitsSegue"
        static let prioritiesToMentalHealthSegue: String = "prioritiesToMentalHealthSegue"
        static let prioritiesToFinancialManagementSegue: String = "prioritiesToFinancialManagementSegue"
        static let forDataOffersToLocaleSegue: String = "forDataOffersToLocaleSegue"
        static let loginViewController: String = "LoginViewController"
        static let detailsToSocialFeed: String = "detailsToSocialFeed"
        static let imagePopUpViewController: String = "ImagePopUpViewController"
        static let imagePageViewController: String = "ImagePageViewController"
        static let loadingScreen: String = "loadingScreen"
        static let textPopUpViewController: String = "textPopUpViewController"
    }
    
    // MARK: - HAT Endpoints
    
    struct HATEndpoints {
        
        static let appRegistrationWithHATURL: String = "https://marketsquare.hubofallthings.com/api/dataplugs/"
        static let contactUs: String = "contact@hatdex.org"
        static let mailingList: String = "http://hatdex.us12.list-manage2.com/subscribe?u=bf49285ca77275f68a5263b83&id=3ca9558266"
        static let purchaseHat: String = "https://hatters.hubofallthings.com/api/products/hat/purchase"
        
        static func hatLoginURL(userDomain: String) -> String {
            
            return "https://\(userDomain)/hatlogin?name=\(Constants.Auth.serviceName)&redirect=\(Constants.Auth.urlScheme)://\(Constants.Auth.localAuthHost)"
        }
        
        static func fileInfoURL(fileID: String, userDomain: String) -> String {
            
            return "https://\(userDomain)/api/v2/files/content/\(fileID)"
        }
        
        /**
         Should be performed before each data post request as token lifetime is short.
         
         - parameter userDomain: The user's domain
         
         - returns: UserHATAccessTokenURLAlias
         */
//        static func theUserHATAccessTokenURL(userDomain: String) -> Constants.UserHATAccessTokenURLAlias {
//            
//            return "https://\(userDomain)/users/access_token?username=\(Constants.HATDataPlugCredentials.hatUsername)&password=\(Constants.HATDataPlugCredentials.hatPassword)"
//        }
        
        /**
         Constructs the url to access the table we want
         
         - parameter tableName: The table name
         - parameter sourceName: The source name
         - parameter userDomain: The user's domain
         
         - returns: String
         */
        static func theUserHATCheckIfTableExistsURL(tableName: String, sourceName: String, userDomain: String) -> String {
            
            return "https://\(userDomain)/data/table?name=\(tableName)&source=\(sourceName)"
        }
        
        /**
         Constructs the URL in order to create new table. Should be performed only if there isn’t an existing data source already.
         
         - parameter userDomain: The user's domain
         
         - returns: String
         */
        static func theConfigureNewDataSourceURL(userDomain: String) -> String {
            
            return "https://\(userDomain)/data/table"
        }
        
        /**
         Constructs the URL to get a field from a table
         
         - parameter fieldID: The fieldID number
         - parameter userDomain: The user's domain
         
         - returns: String
         */
        static func theGetFieldInformationUsingTableIDURL(_ fieldID: Int, userDomain: String) -> String {
            
            return "https://\(userDomain)/data/table/\(String(fieldID))"
        }
        
        /**
         Constructs the URL to post data to HAT
         
         - parameter userDomain: The user's domain
         
         - returns: String
         */
        static func thePOSTDataToHATURL(userDomain: String) -> String {
            
            return "https://\(userDomain)/data/record/values"
        }
    }
}
