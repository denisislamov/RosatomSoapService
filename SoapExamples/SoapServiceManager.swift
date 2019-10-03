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

    public func xmlParserRespond(input: String, xmlParserDelegate : XMLParserDelegate ) -> Bool {
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

extension String {
    func slice(from: String, to: String) -> String? {
        (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }

    func removeEmptyLines() -> String? {
        let lines = self.split { $0.isNewline }
        return lines.joined(separator: "\n")
    }
}
