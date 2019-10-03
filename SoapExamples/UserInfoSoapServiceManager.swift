//
//  UserInfoSoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 03/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol UserInfoSoapServiceManagerDelegate : SoapServiceManagerDelegate {
    func userInfoReceived(value : UserInfo)
    func userGroupReceived(value: UserGroup)
}

class UserInfoSoapServiceManager : SoapServiceManager {
    public func getUserInfo(token : String) {
        let soapAuthMessage : String = RosatomSoapMessages.userInfo(token: token)
        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingXmlUserInfo)
        })
    }

    private func parsingXmlUserInfo(input: String) -> SoapServiceResult<String> {
        if input.contains("<fullname>") {
            var userInfo = UserInfo()
            userInfo.fullName = input.slice(from: "<fullname>", to: "</fullname>")!
            userInfo.position = input.slice(from: "<position>", to: "</position>")!
            userInfo.org      = input.slice(from: "<org>", to: "</org>")!
            userInfo.email    = input.slice(from: "<email>", to: "</email>")!

            if let userInfoSoapServiceManagerDelegate =  soapServiceManagerDelegate as? UserInfoSoapServiceManagerDelegate {
                userInfoSoapServiceManagerDelegate.userInfoReceived(value: userInfo)
                return SoapServiceResult.Success("Success get user info")
            }
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }

    public func getUserGroup(token : String) {
        let soapAuthMessage : String = RosatomSoapMessages.userGroupInfo(token: token)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingUserGroup)
        })
    }

    private func parsingUserGroup(input: String) -> SoapServiceResult<String> {
        if input.contains("<event>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = UserGroupParserDelegate()
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                if let userInfoSoapServiceManagerDelegate =  soapServiceManagerDelegate as? UserInfoSoapServiceManagerDelegate {
                    userInfoSoapServiceManagerDelegate.userGroupReceived(value: delegate.userGroup)
                    return SoapServiceResult.Success("Success get user group info")
                }
            }
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}
