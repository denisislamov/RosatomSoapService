//
//  UserInAppSoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 03/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol UserInAppSoapServiceManagerDelegate : SoapServiceManagerDelegate {
     func userInAppTokenReceived(value: String)
}

class UserInAppSoapServiceManager : SoapServiceManager {
     public func sendInAppUserToken(token: String, inAppToken: String) {
        let soapAuthMessage : String = RosatomSoapMessages.sendInAppUserToken(token: token, inAppToken: inAppToken)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingSendInAppUserTokenRespond)
        })
    }

    private func parsingSendInAppUserTokenRespond(input: String) -> SoapServiceResult<String> {
        if input.contains("SetPushTokenResponse") {
           return SoapServiceResult.Success("Success send inApp token")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }

    public func getInAppUserToken(token: String) {
        let soapAuthMessage : String = RosatomSoapMessages.getInAppUserToken(token: token)

        sendRequest(requests : soapAuthMessage, completion: { result in
           self.soapRequestСompletion(result: result, parsingFunc: self.parsingInAppUserToken)
        })
    }

    private func parsingInAppUserToken(input: String) -> SoapServiceResult<String> {
        if input.contains("<token>") {
            if let userInAppSoapServiceManagerDelegate =  soapServiceManagerDelegate as? UserInAppSoapServiceManagerDelegate {
                userInAppSoapServiceManagerDelegate.userInAppTokenReceived(value: input.slice(from: "<token>", to: "</token>")!)
                return SoapServiceResult.Success("Success get user inApp token")
            }
        } else if input.contains("<GetPushTokenResponse>") {
            return SoapServiceResult.Success("No inApp token for this user")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}
