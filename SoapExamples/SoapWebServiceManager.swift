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
    func TokenReceived(value : String)
    func UserInfoReceived(value : UserInfo)
    func ErrorReceived(value : String)
}

class SoapWebServiceManager {
    private weak var soapWebServiceDelegate : SoapWebServiceDelegate?

    public init(soapWebServiceDelegateRef : SoapWebServiceDelegate) {
        soapWebServiceDelegate = soapWebServiceDelegateRef
    }

    public func GetUserInfo(token : String) {
        let soapAuthMessage : String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n                <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n                    <soapenv:Header>\n                        <sdo:Token>\n                            <sdo:authtoken>\(token)</sdo:authtoken>\n                    </sdo:Token>\n                    </soapenv:Header>\n                    <soapenv:Body>\n                        <sdo:UserInfo></sdo:UserInfo>\n                    </soapenv:Body>\n                </soapenv:Envelope>"
        sendRequest(requests : soapAuthMessage, completion: { result in
            switch result {
            case SoapWebServiceResult.Success(let response):
                self.parsingXmlUserInfo(input: response);
                break
            case SoapWebServiceResult.Failure(let error):
                self.soapWebServiceDelegate?.ErrorReceived(value: error)
                break
            }
        })
    }

    public func GetToken(login : String, pass : String, secret : String) {
        let soapAuthMessage : String = "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n                <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n                    <soap:Body>\n                    <Auth xmlns:ns1=\"http://sdo-test.scicet.local/\" username=\"\(login)\" password=\"\(pass)\" secret=\"\(secret)\"/>\n                    </soap:Body>\n                </soap:Envelope>"

        sendRequest(requests : soapAuthMessage, completion: { result in
            switch result {
            case SoapWebServiceResult.Success(let response):
                self.parsingXmlToken(input: response)
            case SoapWebServiceResult.Failure(let error):
                self.soapWebServiceDelegate?.ErrorReceived(value: error)
                break
            }
        })
    }

    private func parsingXmlToken(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<token>") {
            soapWebServiceDelegate?.TokenReceived(value: input.slice(from: "<token>", to: "</token>")!)
            return SoapWebServiceResult.Success("Success get user token")
        }

        if input.contains("<soap:Fault>") {
            let errorMsg = input.slice(from: "<faultstring>", to: "</faultstring>")!

            soapWebServiceDelegate?.ErrorReceived(value: errorMsg)
            return  SoapWebServiceResult.Failure(errorMsg)
        }

        soapWebServiceDelegate?.ErrorReceived(value: "Unknown error")
        return SoapWebServiceResult.Failure("Unknown error")
    }

    private func parsingXmlUserInfo(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<fullname>") {
            var userInfo = UserInfo()
            userInfo.fullName = input.slice(from: "<fullname>", to: "</fullname>")!
            userInfo.position = input.slice(from: "<position>", to: "</position>")!
            userInfo.org      = input.slice(from: "<org>", to: "</org>")!
            userInfo.email    = input.slice(from: "<email>", to: "</email>")!

            soapWebServiceDelegate?.UserInfoReceived(value: userInfo)
            return SoapWebServiceResult.Success("Success get user info")
        }

        if input.contains("<soap:Fault>") {
            let errorMsg = input.slice(from: "<faultstring>", to: "</faultstring>")!
            soapWebServiceDelegate?.ErrorReceived(value: errorMsg)
            return  SoapWebServiceResult.Failure(errorMsg)

        }
        soapWebServiceDelegate?.ErrorReceived(value: "Unknown error")
        return SoapWebServiceResult.Failure("Unknown error")
    }

    private func sendRequest(requests : String, completion: @escaping (SoapWebServiceResult<String>) -> Void) {
        let is_URL: String = "https://sdo.rosatomtech.ru/sdo-cicet/service/vgService.html"

        let lobjRequest = NSMutableURLRequest(url: NSURL(string: is_URL)! as URL)
        let session = URLSession.shared
        var _: NSError?

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
