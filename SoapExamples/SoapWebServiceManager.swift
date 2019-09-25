//
// Created by Denis Islamov on 21/09/2019.
// Copyright (c) 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

enum SoapWebServiceResult<T> {
    case Success(T)
    case Failure(T)
}

protocol SoapWebServiceDelegate : class {
    func tokenReceived(value : String)
    func userInfoReceived(value : UserInfo)
    func userGroupReceived(value: UserGroup)
    func errorReceived(value : String)
}

class SoapWebServiceManager {
    private weak var soapWebServiceDelegate : SoapWebServiceDelegate?

    public init(soapWebServiceDelegateRef : SoapWebServiceDelegate) {
        soapWebServiceDelegate = soapWebServiceDelegateRef
    }

    public func getToken(login : String, pass : String, secret : String) {
        let soapAuthMessage : String = RosatomSoapMessages.auth(login, pass, secret)

        sendRequest(requests : soapAuthMessage, completion: { result in
            switch result {
            case SoapWebServiceResult.Success(let response):
                self.parsingXmlToken(input: response)
            case SoapWebServiceResult.Failure(let error):
                self.soapWebServiceDelegate?.errorReceived(value: error)
                break
            }
        })
    }

    private func parsingXmlToken(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<token>") {
            soapWebServiceDelegate?.tokenReceived(value: input.slice(from: "<token>", to: "</token>")!)
            return SoapWebServiceResult.Success("Success get user token")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return  SoapWebServiceResult.Failure(errorDescription)
    }

    public func getUserInfo(token : String) {
        let soapAuthMessage : String = RosatomSoapMessages.userInfo(token)
        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingXmlUserInfo)
        })
    }

    private func parsingXmlUserInfo(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<fullname>") {
            var userInfo = UserInfo()
            userInfo.fullName = input.slice(from: "<fullname>", to: "</fullname>")!
            userInfo.position = input.slice(from: "<position>", to: "</position>")!
            userInfo.org      = input.slice(from: "<org>", to: "</org>")!
            userInfo.email    = input.slice(from: "<email>", to: "</email>")!

            soapWebServiceDelegate?.userInfoReceived(value: userInfo)
            return SoapWebServiceResult.Success("Success get user info")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return  SoapWebServiceResult.Failure(errorDescription)
    }

    public func getUserGroup(token : String) {
        let soapAuthMessage : String = RosatomSoapMessages.userGroupInfo(token)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingUserGroup)
        })
    }

    private func soapRequestСompletion(result : SoapWebServiceResult<String>, parsingFunc:(_:String) -> SoapWebServiceResult<String>) -> Void {
        switch result {
        case SoapWebServiceResult.Success(let response):
            parsingFunc(response);
            break
        case SoapWebServiceResult.Failure(let error):
            self.soapWebServiceDelegate?.errorReceived(value: error)
            break
        }
    }

    // TODO - move xml parser to different function
    private func parsingUserGroup(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<event>") {
            let lines = input.split { $0.isNewline }
            var result = lines.joined(separator: "\n")
            result = result.slice(from: "Optional(", to: ")")!
            let xmlParser = XMLParser(data: result.data(using: .utf16)!)

            let delegate = UserGroupParserDelegate()
            xmlParser.delegate = delegate

            if xmlParser.parserError != nil {
                print("parserError \(xmlParser.parserError.debugDescription)")

                soapWebServiceDelegate?.errorReceived(value: xmlParser.parserError.debugDescription)
                return SoapWebServiceResult.Failure(xmlParser.parserError.debugDescription)
            }
            if xmlParser.parse() {
                soapWebServiceDelegate?.userGroupReceived(value: delegate.userGroup)
                return SoapWebServiceResult.Success("Success get user group info")
            }
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }

    private func sendRequest(requests : String, completion: @escaping (SoapWebServiceResult<String>) -> Void) {
        let lobjRequest = NSMutableURLRequest(url: NSURL(string: RosatomSoapMessages.soapServiceUrl)! as URL)
        let session = URLSession.shared

        lobjRequest.httpMethod = "POST"
        lobjRequest.httpBody = requests.data(using: .utf8)
        lobjRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        lobjRequest.addValue(String(requests.count), forHTTPHeaderField: "Content-Length")
        lobjRequest.addValue("http://www.cgsapi.com/GetSystemStatus", forHTTPHeaderField: "SOAPAction")

        let task = session.dataTask(with: lobjRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
            let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)

            if error != nil {
                completion(SoapWebServiceResult.Failure(error.debugDescription))
            } else {
                completion(SoapWebServiceResult.Success(String(describing: strData)))
            }
        })
        task.resume()
    }

    private func errorHandler(value: String) -> String {
        if value.contains("<soap:Fault>") {
            let errorMsg = value.slice(from: "<faultstring>", to: "</faultstring>")!
            return errorMsg
        }

        return "Unknown error"
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }
}
