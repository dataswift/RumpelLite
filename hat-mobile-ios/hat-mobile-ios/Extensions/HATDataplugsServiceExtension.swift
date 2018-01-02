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

// MARK: Extension

extension HATDataPlugsService: UserCredentialsProtocol {
    
    // MARK: - Wrappers
    
    /**
     Ensure if the data plug is ready
     
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter tokenErrorCallback: A function to call if there is something wrong with the token
     - parameter failCallBack: A function to call if fail
     */
    static func ensureOffersReady(succesfulCallBack: @escaping (String) -> Void, tokenErrorCallback: @escaping () -> Void, failCallBack: @escaping (DataPlugError) -> Void) {
        
        // set up the succesfulCallBack
        let plugReadyContinue = ensureOfferEnabled(
                                    offerID: Constants.DataPlug.offerID,
                                    succesfulCallBack: succesfulCallBack,
                                    tokenErrorCallback: tokenErrorCallback,
                                    failCallBack: failCallBack)
        
        func checkPlugForToken(appToken: String, renewedUserToken: String?) {

            plugReadyContinue(appToken)
        }
        
        // get token async
        HATService.getApplicationTokenFor(
            serviceName: Constants.ApplicationToken.Dex.name,
            userDomain: userDomain,
            token: userToken,
            resource: Constants.ApplicationToken.Dex.source,
            succesfulCallBack: checkPlugForToken,
            failCallBack: { (error) in
            
                switch error {
                    
                case .noInternetConnection:
                    
                    failCallBack(.noInternetConnection)
                default:
                    
                    tokenErrorCallback()
                    CrashLoggerHelper.JSONParsingErrorLogWithoutAlert(error: error)
                }
            }
        )
    }
    
    /**
     Ensures offer is enabled
     
     - parameter offerID: The offerID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter tokenErrorCallback: A function to call if there is something wrong with the token
     - parameter failCallBack: A function to call if fail
     */
    static func ensureOfferEnabled(offerID: String, succesfulCallBack: @escaping (String) -> Void, tokenErrorCallback: @escaping () -> Void, failCallBack: @escaping (DataPlugError) -> Void) -> (String) -> Void {
        
        return {_ in
            
            // setup succesfulCallBack
            func offerClaimForToken(appToken: String, renewedUserToken: String?) {
                
                ensureOfferDataDebitEnabled(
                    offerID: offerID,
                    succesfulCallBack: succesfulCallBack,
                    failCallBack: failCallBack
                )(appToken)
            }
            
            // get applicationToken async
            HATService.getApplicationTokenFor(
                serviceName: Constants.ApplicationToken.Dex.name,
                userDomain: userDomain,
                token: userToken,
                resource: Constants.ApplicationToken.Dex.source,
                succesfulCallBack: offerClaimForToken,
                failCallBack: { (error) in
                
                    switch error {
                        
                    case .noInternetConnection:
                        
                        failCallBack(.noInternetConnection)
                    default:
                        
                        tokenErrorCallback()
                        CrashLoggerHelper.JSONParsingErrorLogWithoutAlert(error: error)
                    }
                }
            )
        }
    }
    
    /**
     Ensures offer data debit is enabled
     
     - parameter offerID: The offerID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    static func ensureOfferDataDebitEnabled(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (DataPlugError) -> Void) -> (_ appToken: String) -> Void {
        
        return { (appToken: String) in
            
            // setup the succesfulCallBack
            let claimDDForOffer = approveDataDebitPartial(
                appToken: appToken,
                succesfulCallBack: succesfulCallBack,
                failCallBack: failCallBack)
            
            // ensure offer is claimed
            ensureOfferClaimed(
                offerID: offerID,
                succesfulCallBack: claimDDForOffer,
                failCallBack: failCallBack)(appToken)
        }
    }
    
    /**
     Ensure offer claimed
     
     - parameter offerID: The offerID as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    static func ensureOfferClaimed(offerID: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (DataPlugError) -> Void) -> (_ appToken: String) -> Void {
        
        return { (appToken: String) in
            
            // setup the succesfulCallBack
            let claimOfferIfFailed = claimOfferWithOfferIDPartial(
                offerID: offerID,
                appToken: appToken,
                succesfulCallBack: succesfulCallBack,
                failCallBack: failCallBack)
            // ensure offer is claimed
            self.checkIfOfferIsClaimed(
                offerID: offerID,
                appToken: appToken,
                succesfulCallBack: succesfulCallBack,
                failCallBack: { (_) in
                
                    claimOfferIfFailed()
                }
            )
        }
    }
    
    /**
     Claims offer for this offerID
     
     - parameter offerID: The offerID as a String
     - parameter appToken: The application token as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    static func claimOfferWithOfferIDPartial(offerID: String, appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (DataPlugError) -> Void) -> () -> Void {
        
        return {
            
            // claim offer
            self.claimOfferWithOfferID(
                offerID,
                appToken: appToken,
                succesfulCallBack: succesfulCallBack,
                failCallBack: { (error) in
                
                    failCallBack(error)
                    CrashLoggerHelper.dataPlugErrorLog(error: error)
                }
            )
        }
    }
    
    /**
     Approve data debit
     
     - parameter appToken: The application token as a String
     - parameter succesfulCallBack: A function to call if everything is ok
     - parameter failCallBack: A function to call if fail
     */
    static func approveDataDebitPartial(appToken: String, succesfulCallBack: @escaping (String) -> Void, failCallBack: @escaping (DataPlugError) -> Void) -> (_ dataDebitID: String) -> Void {
        
        return { (dataDebitID: String) in
            
            // approve data debit
            self.approveDataDebit(
                dataDebitID,
                userToken: userToken,
                userDomain: userDomain,
                succesfulCallBack: succesfulCallBack,
                failCallBack: { (error) in
                
                    failCallBack(error)
                    CrashLoggerHelper.dataPlugErrorLog(error: error)
                }
            )
        }
    }
    
    // MARK: - Create URL
    
    /**
     Creates the url to connect to
     
     - parameter socialServiceName: The name of the social service
     - parameter socialServiceURL: The url of the social service
     
     - returns: A ready URL as a String if everything ok else nil
     */
    public static func createURLBasedOn(socialServiceName: String, socialServiceURL: String, appToken: String? = nil) -> String? {
        
        if socialServiceName == "twitter" {
            
            guard let token = appToken else {
                
                return (Constants.DataPlug.twitterDataPlugServiceURL(userDomain: self.userDomain, socialServiceURL: socialServiceURL, appToken: ""))
            }
            
            return (Constants.DataPlug.twitterDataPlugServiceURL(userDomain: self.userDomain, socialServiceURL: socialServiceURL, appToken: token))
        } else if socialServiceName == "facebook" {
            
            guard let token = appToken else {
                
                return Constants.DataPlug.facebookDataPlugServiceURL(
                    userDomain: self.userDomain,
                    socialServiceURL: socialServiceURL,
                    appToken: "")
            }
            
            return Constants.DataPlug.facebookDataPlugServiceURL(
                userDomain: self.userDomain,
                socialServiceURL: socialServiceURL,
                appToken: token)
        } else if socialServiceName == "Fitbit" {
            
            guard let token = appToken else {
                
                return (Constants.DataPlug.fitbitDataPlugServiceURL(userDomain: self.userDomain, socialServiceURL: socialServiceURL, appToken: ""))
            }
            
            return (Constants.DataPlug.fitbitDataPlugServiceURL(userDomain: self.userDomain, socialServiceURL: socialServiceURL, appToken: token))
        }
        
        return nil
    }
    
    // MARK: - Check status of the plugs
    
    /**
     Checks the status of the plug
     
     - parameter dataPlug: The data plug to check status
     - parameter userDomain: The user's domain
     - parameter userToken: The user's token
     - parameter completion: A function, accepting (Bool, String?), to execute on completion
     */
    static func checkStatusOfPlug(dataPlug: HATDataPlugObject, userDomain: String, userToken: String, completion: @escaping (Bool, String?) -> Void) {
        
        func gotFacebookApplicationToken(appToken: String, newUserToken: String?) {
            
            let systemStatus = Facebook.facebookDataPlugStatusURL(facebookDataPlugURL: dataPlug.plug.url)
            
            HATFacebookService.isFacebookDataPlugActive(
                appToken: appToken,
                url: systemStatus,
                successful: { result in
                    
                    completion(result, appToken)
            },
                failed: checkingPlugStatusFailed)
        }
        
        func gotTwitterApplicationToken(appToken: String, newUserToken: String?) {
            
            let systemStatus = Twitter.twitterDataPlugStatusURL(twitterDataPlugURL: dataPlug.plug.url)
            
            HATTwitterService.isTwitterDataPlugActive(
                appToken: appToken,
                url: systemStatus,
                successful: { result in
                    
                    completion(result, appToken)
            },
                failed: checkingPlugStatusFailed)
        }
        
        func gettingApplicationTokenFailed(error: JSONParsingError) {
            
            completion(false, nil)
        }
        
        func checkingPlugStatusFailed(error: DataPlugError) {
            
            completion(false, nil)
        }
        
        if dataPlug.plug.name == Constants.DataPlug.DataPlugNames.facebook {
            
            HATFacebookService.getAppTokenForFacebook(
                plug: dataPlug,
                token: userToken,
                userDomain: userDomain,
                successful: gotFacebookApplicationToken,
                failed: gettingApplicationTokenFailed)
        } else if dataPlug.plug.name == Constants.DataPlug.DataPlugNames.twitter {
            
            HATTwitterService.getAppTokenForTwitter(
                plug: dataPlug,
                userDomain: userDomain,
                token: userToken,
                successful: gotTwitterApplicationToken,
                failed: gettingApplicationTokenFailed)
        } else if dataPlug.plug.name == Constants.DataPlug.DataPlugNames.fitbit {
            
            let statusURL = Fitbit.fitbitDataPlugStatusURL(fitbitDataPlugURL: dataPlug.plug.url)
            HATFitbitService.checkIfFitbitIsEnabled(
                userDomain: userDomain,
                userToken: userToken,
                plugURL: dataPlug.plug.url,
                statusURL: statusURL,
                successCallback: completion,
                errorCallback: gettingApplicationTokenFailed)
        }
    }
    
    // MARK: - Filter available data plugs
    
    /**
     Filters the available dataplugs down to 2, facebook and twitter
     
     - parameter dataPlugs: An array of HATDataPlugObject containing the full list of available data plugs
     
     - returns: A filtered array of HATDataPlugObject
     */
    public static func filterAvailableDataPlugs(dataPlugs: [HATDataPlugObject]) -> [HATDataPlugObject] {
        
        var tempDataPlugs = dataPlugs
        // remove the existing dataplugs from array
        tempDataPlugs.removeAll()
        
        // we want only facebook and twitter, so keep those
        for i in 0 ... dataPlugs.count - 1 {
            
            if dataPlugs[i].plug.name == "twitter" || dataPlugs[i].plug.name == "facebook" || dataPlugs[i].plug.name == "Fitbit" {
                
                tempDataPlugs.append(dataPlugs[i])
            }
        }
        
        return tempDataPlugs
    }
}
