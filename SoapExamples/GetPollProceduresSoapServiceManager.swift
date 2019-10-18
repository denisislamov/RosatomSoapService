//
//  GetPollProcedures.swift
//  SoapExamples
//
//  Created by Denis Islamov on 16/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol GetPollProceduresServiceManagerDelegate : SoapServiceManagerDelegate {
    func getPollProceduresReceived(value: [PollProcedureData])
}

class GetPollProceduresSoapServiceManager : SoapServiceManager {
    public func getPollProcedures(token: String) {
        let soapAuthMessage : String = RosatomSoapMessages.getAllPolls(token: token)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingPollProcedures)
        })
    }

    private func parsingPollProcedures(input: String) -> SoapServiceResult<String> {
        print(input)
        if input.contains("<poll_procedures>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = GetPollProceduresDelegate()
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                if let getPollProceduresServiceManagerDelegate =  soapServiceManagerDelegate as? GetPollProceduresServiceManagerDelegate {
                    getPollProceduresServiceManagerDelegate.getPollProceduresReceived(value: delegate.pollProceduresData)
                    return SoapServiceResult.Success("Success get poll procedures")
                }
            }
        } else if input.contains("GetPollProceduresResponse") {
            return SoapServiceResult.Success("Can't get poll procedures for this user")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}

class GetPollProceduresDelegate : NSObject, XMLParserDelegate {
    var pollProceduresData : [PollProcedureData] = []
    var newPollProcedureData : PollProcedureData? = nil

    enum StatePollProcedures { case none, id, code, name }
    var statePollProcedures : StatePollProcedures = .none

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "poll_procedure":
            self.newPollProcedureData = PollProcedureData()
            self.statePollProcedures = .none
        case "id":
            self.statePollProcedures = .id
        case "code":
            self.statePollProcedures = .code
        case "name":
            self.statePollProcedures = .name
        default:
            self.statePollProcedures = .none
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let newPollProcedureData = self.newPollProcedureData, elementName == "poll_procedure" {
            self.pollProceduresData.append(newPollProcedureData)
            self.newPollProcedureData = nil
        }

        self.statePollProcedures = .none
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let _ = self.newPollProcedureData else { return }

        switch self.statePollProcedures {
        case .id:
            self.newPollProcedureData!.id = string
        case .code:
            self.newPollProcedureData!.code = string
        case .name:
            self.newPollProcedureData!.name = string
        default:
            break
        }
    }
}
