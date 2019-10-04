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
    func tokenInfoReceived(value : TokenInfo)
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

    private func decodeToken(token : String) -> String {
        return String(data: Data(base64Encoded: token)!, encoding: .utf8)!
    }

    public func parseDecodeToken(input: String) {
        let data = Data(decodeToken(token: input).utf8)

        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                var tokenInfo : TokenInfo = TokenInfo()
                if let token_id = json["token_id"] {
                    tokenInfo.tokenId = "\(token_id)"
                }

                if let person_id = json["person_id"] {
                    tokenInfo.personId = "\(person_id)"
                }

                if let expired_date = json["expired_date"] {
                    tokenInfo.expiredDate = "\(expired_date)"
                }

                if let roles = json["roles"] {
                    tokenInfo.roles = "\(roles)"
                }

                if let authSoapServiceManagerDelegate =  soapServiceManagerDelegate as? AuthSoapServiceManagerDelegate {
                    authSoapServiceManagerDelegate.tokenInfoReceived(value: tokenInfo)
                }
            }
        } catch let error as NSError {
            soapServiceManagerDelegate?.errorReceived(value: error.localizedDescription)
        }
    }
}
