//
//  TutorPollsSoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 11/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol TutorPollsSoapServiceManagerDelegate : SoapServiceManagerDelegate {
    func tutorPollsReceived(value: [TutorPoll])
}

class TutorPollsSoapServiceManager : SoapServiceManager {
    public func getTutorPolls(token: String) {
        let soapAuthMessage : String = RosatomSoapMessages.getAllPolls(token: token)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingTutorPolls)
        })
    }

    private func parsingTutorPolls(input: String) -> SoapServiceResult<String> {
        print(input)
        if input.contains("<polls>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = TutorPollParserDelegate()
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                if let tutorPollsSoapServiceManagerDelegate =  soapServiceManagerDelegate as? TutorPollsSoapServiceManagerDelegate {
                    tutorPollsSoapServiceManagerDelegate.tutorPollsReceived(value: delegate.tutorPolls)
                    return SoapServiceResult.Success("Success get tutor polls info")
                }
            }
        } else if input.contains("GetAllPollsResponse") {
            return SoapServiceResult.Success("No tutor polls for this user")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}

class TutorPollParserDelegate : NSObject, XMLParserDelegate {
    var tutorPolls : [TutorPoll] = []
    var newTutorPoll : TutorPoll? = nil

    enum StateTutorPoll { case none, id, code, name }
    var stateTutorPoll : StateTutorPoll = .none

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "poll":
            self.newTutorPoll = TutorPoll()
            self.stateTutorPoll = .none
        case "id":
            self.stateTutorPoll = .id
        case "name":
            self.stateTutorPoll = .name
        case "code":
            self.stateTutorPoll = .code
        default:
            self.stateTutorPoll = .none
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let newTutorPoll = self.newTutorPoll, elementName == "poll" {
            self.tutorPolls.append(newTutorPoll)
            self.newTutorPoll = nil
        }

        self.stateTutorPoll = .none
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let _ = self.newTutorPoll else { return }

        switch self.stateTutorPoll {
        case .id:
            self.newTutorPoll!.id = string
        case .name:
            self.newTutorPoll!.name = string
        case .code:
            self.newTutorPoll!.code = string
        default:
            break
        }
    }
}

