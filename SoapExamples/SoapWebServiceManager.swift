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
    func errorReceived(value : String)
}

class SoapWebServiceManager {
    private weak var soapWebServiceDelegate : SoapWebServiceDelegate?

    public init(soapWebServiceDelegateRef : SoapWebServiceDelegate) {
        soapWebServiceDelegate = soapWebServiceDelegateRef
    }

    
    private func xmlParserRespond(input: String, xmlParserDelegate : XMLParserDelegate ) -> Bool {
        let xmlParser = XMLParser(data: (input.data(using: .utf16))!)
        xmlParser.delegate = xmlParserDelegate

        return xmlParser.parse()
    }

    private func soapRequestСompletion(result: SoapWebServiceResult<String>, parsingFunc:(_:String) -> SoapWebServiceResult<String>) -> Void {
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
