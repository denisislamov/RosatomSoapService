//
//  SoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 03/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

enum SoapServiceResult<T> {
    case Success(T)
    case Failure(T)
}

protocol SoapServiceManagerDelegate : class {
    func errorReceived(value : String)
}

class SoapServiceManager {
    public weak var soapServiceManagerDelegate : SoapServiceManagerDelegate?
    private var soapServiceUrl : String

    public init(soapWebServiceDelegateRef : SoapServiceManagerDelegate, soapUrl : String) {
        soapServiceManagerDelegate = soapWebServiceDelegateRef
        soapServiceUrl = soapUrl
    }

    private func xmlParserRespond(input: String, xmlParserDelegate : XMLParserDelegate ) -> Bool {
        let xmlParser = XMLParser(data: (input.data(using: .utf16))!)
        xmlParser.delegate = xmlParserDelegate

        return xmlParser.parse()
    }

    public func soapRequestСompletion(result: SoapServiceResult<String>, parsingFunc:(_:String) -> SoapServiceResult<String>) -> Void {
        switch result {
        case SoapServiceResult.Success(let response):
            parsingFunc(response);
            break
        case SoapServiceResult.Failure(let error):
            self.soapServiceManagerDelegate?.errorReceived(value: error)
            break
        }
    }

    public func sendRequest(requests : String, completion: @escaping (SoapServiceResult<String>) -> Void) {
        let lobjRequest = NSMutableURLRequest(url: NSURL(string: soapServiceUrl)! as URL)
        let session = URLSession.shared

        lobjRequest.httpMethod = "POST"
        lobjRequest.httpBody = requests.data(using: .utf8)
        lobjRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        lobjRequest.addValue(String(requests.count), forHTTPHeaderField: "Content-Length")
        lobjRequest.addValue("http://www.cgsapi.com/GetSystemStatus", forHTTPHeaderField: "SOAPAction")

        let task = session.dataTask(with: lobjRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
            let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)

            if error != nil {
                completion(SoapServiceResult.Failure(error.debugDescription))
            } else {
                completion(SoapServiceResult.Success(String(describing: strData)))
            }
        })
        task.resume()
    }

    public func errorHandler(value: String) -> String {
        if value.contains("<soap:Fault>") {
            let errorMsg = value.slice(from: "<faultstring>", to: "</faultstring>")!
            return errorMsg
        }

        return "Unknown error"
    }
}

protocol AuthSoapServiceManagerDelegate : SoapServiceManagerDelegate {
    func tokenReceived(value : String)
    func userInfoReceived(value : UserInfo)
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
