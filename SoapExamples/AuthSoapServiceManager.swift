//
//  AuthSoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 03/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol AuthSoapServiceManagerDelegate : SoapServiceManagerDelegate {
    func tokenReceived(value : String)
}

class AuthSoapServiceManager : SoapServiceManager {
    public func getToken(login : String, pass : String, secret : String) {
       let soapAuthMessage : String = RosatomSoapMessages.auth(login: login, pass: pass, secret: secret)

       sendRequest(requests : soapAuthMessage, completion: { result in
           self.soapRequestСompletion(result: result, parsingFunc: self.parsingXmlToken)
       })
    }

    private func parsingXmlToken(input: String) -> SoapServiceResult<String> {
       if input.contains("<token>") {
           if let authSoapServiceManagerDelegate =  soapServiceManagerDelegate as? AuthSoapServiceManagerDelegate {
               authSoapServiceManagerDelegate.tokenReceived(value: input.slice(from: "<token>", to: "</token>")!)
               return SoapServiceResult.Success("Success get user token")
           }
       }

       let errorDescription = errorHandler(value: input)
       soapServiceManagerDelegate?.errorReceived(value: errorDescription)
       return  SoapServiceResult.Failure(errorDescription)
    }

    public func logout(token: String) {
       let soapAuthMessage : String = RosatomSoapMessages.logout(token: token)

       sendRequest(requests : soapAuthMessage, completion: { result in
           self.soapRequestСompletion(result: result, parsingFunc: self.logoutRespond)
       })
    }

    private func logoutRespond(input: String) -> SoapServiceResult<String> {
       if input.contains("LogoutResponse") {
           return SoapServiceResult.Success("Success logout")
       }

       let errorDescription = errorHandler(value: input)
       soapServiceManagerDelegate?.errorReceived(value: errorDescription)
       return  SoapServiceResult.Failure(errorDescription)
    }
}
