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
import JWTDecode
import SwiftyRSA

// MARK: Struct

/// The login service class
public struct HATLoginService {

    /**
     Log in button pressed. Begin authorization
     
     - parameter userHATDomain: The user's domain
     - parameter successfulVerification: The function to execute on successful verification
     - parameter failedVerification: The function to execute on failed verification
     */
    public static func formatAndVerifyDomain(userHATDomain: String, successfulVerification: @escaping (String) -> Void, failedVerification: @escaping (String) -> Void) {

        // trim values
        let hatDomain = userHATDomain.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let result = hatDomain.hasSuffixes(["hubofallthings.net", "savy.io", "hubat.net"])

        // verify if the domain is what we want
        if result {

            // domain accepted
            successfulVerification(userHATDomain)
        } else {

            // domain is incorrect
            let message = NSLocalizedString("The domain you entered is incorrect. Accepted domains are 'hubofallthings.net, savy.io and hubat.net. Please correct any typos and try again", comment: "")
            failedVerification(message)
        }
    }

    /**
     Log in authorization process
     
     - parameter userDomain: The user's domain
     - parameter url: The url to connect
     - parameter success: A function to execute after finishing
     */
    public static func loginToHATAuthorization(userDomain: String, url: NSURL, success: ((String?) -> Void)?, failed: ((AuthenicationError) -> Void)?) {

        // get token out
        if let token = HATNetworkHelper.getQueryStringParameter(url: url.absoluteString, param: Auth.TokenParamName) {

            // make asynchronous call
            // parameters..
            let parameters: Dictionary<String, String> = [:]
            // auth header
            let headers = ["Accept": ContentType.Text, "Content-Type": ContentType.Text]

            if let url = HATAccountService.theUserHATDomainPublicKeyURL(userDomain) {

                //. application/json
                HATNetworkHelper.asynchronousStringRequest(url, method: HTTPMethod.get, encoding: Alamofire.URLEncoding.default, contentType: ContentType.Text, parameters: parameters as Dictionary<String, AnyObject>, headers: headers) { (response: HATNetworkHelper.ResultTypeString) -> Void in

                    switch response {
                    case .isSuccess(let isSuccess, let statusCode, let result, _):

                        if isSuccess {

                            // decode the token and get the iss out
                            guard let jwt = try? decode(jwt: token) else {

                                failed?(.cannotDecodeToken(token))
                                return
                            }

                            // guard for the issuer check, “iss” (Issuer)
                            guard jwt.issuer != nil else {

                                failed?(.noIssuerDetectedError(jwt.string))
                                return
                            }

                            /*
                             The token will consist of header.payload.signature
                             To verify the token we use header.payload hashed with signature in base64 format
                             The public PEM string is used to verify also
                             */
                            let tokenAttr: [String] = token.components(separatedBy: ".")

                            // guard for the attr length. Should be 3 [header, payload, signature]
                            guard tokenAttr.count == 3 else {

                                failed?(.cannotSplitToken(tokenAttr))
                                return
                            }

                            // And then to access the individual parts of token
                            let header: String = tokenAttr[0]
                            let payload: String = tokenAttr[1]
                            let signature: String = tokenAttr[2]

                            // decode signature from baseUrl64 to base64
                            let decodedSig = HATFormatterHelper.fromBase64URLToBase64(stringToConvert: signature)

                            // data to be verified header.payload
                            let headerAndPayload = header + "." + payload

                            do {

                                let signature = try Signature(base64Encoded: decodedSig)
                                let privateKey = try PublicKey(pemEncoded: result)
                                let clear = try ClearMessage(string: headerAndPayload, using: .utf8)
                                let isSuccessful = try clear.verify(with: privateKey, signature: signature, digestType: .sha256)

                                if isSuccessful {

                                    success?(token)
                                } else {

                                    failed?(.tokenValidationFailed(isSuccessful.description))
                                }

                            } catch {

                                let message = NSLocalizedString("Proccessing of token failed", comment: "")
                                failed?(.tokenValidationFailed(message))
                            }

                        } else {

                            failed?(.generalError(isSuccess.description, statusCode, nil))
                        }

                    case .error(let error, let statusCode):

                        let message = NSLocalizedString("Server responded with error", comment: "")
                        failed?(.generalError(message, statusCode, error))
                    }
                }
            }
        } else {

            failed?(.noTokenDetectedError)
        }
    }

}
