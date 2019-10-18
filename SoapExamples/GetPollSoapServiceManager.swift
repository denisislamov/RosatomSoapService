//
//  GetPoll.swift
//  SoapExamples
//
//  Created by Denis Islamov on 16/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol GetPollServiceManagerDelegate : SoapServiceManagerDelegate {
    func getPollReceived(value: [PollQuestion])
}

class GetPollSoapServiceManager : SoapServiceManager {
    public func getPoll(token: String, pollProcedureId: String) {
        let soapAuthMessage : String = RosatomSoapMessages.getPoll(token: token, pollProcedureId: pollProcedureId)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingPollProcedures)
        })
    }

    private func parsingPollProcedures(input: String) -> SoapServiceResult<String> {
        print(input)
        if input.contains("<questions>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = GetPollDelegate()
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                if let getPollServiceManagerDelegate =  soapServiceManagerDelegate as? GetPollServiceManagerDelegate {
                    getPollServiceManagerDelegate.getPollReceived(value: delegate.pollQuestions)
                    return SoapServiceResult.Success("Success get poll")
                }
            }
        } else if input.contains("GetPollResponse") {
            return SoapServiceResult.Success("Can't get poll for this user")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}

class GetPollDelegate : NSObject, XMLParserDelegate {
    var pollQuestions : [PollQuestion] = []
    var newPollQuestion : PollQuestion? = nil

    var pollQuestionEntries : [PollQuestionEntry] = []
    var newPollQuestionEntry : PollQuestionEntry? = nil

    enum StatePollQuestion { case none, id, type, text }
    var statePollQuestion : StatePollQuestion = .none

    enum StateEntry { case none, id, value, order }
    var stateEntry : StateEntry = .none

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "question":
            self.newPollQuestion = PollQuestion()
            self.statePollQuestion = .none
        case "id":
            if self.newPollQuestionEntry == nil {
                self.statePollQuestion = .id
            } else {
                self.stateEntry = .id
            }
        case "type":
            self.statePollQuestion = .type
        case "entry":
           self.newPollQuestionEntry = PollQuestionEntry()
           self.stateEntry = .none
        case "value":
           self.stateEntry = .value
        case "order":
           self.stateEntry = .order
        case "text":
            self.statePollQuestion = .text
        default:
            self.statePollQuestion = .none
            self.stateEntry = .none
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let newPollQuestionEntry = self.newPollQuestionEntry, elementName == "entry" {
            self.pollQuestionEntries.append(newPollQuestionEntry)
            self.newPollQuestionEntry = nil
        }

        self.stateEntry = .none

        if elementName == "entry" && self.newPollQuestion != nil {
            self.newPollQuestion!.pollQuestionEntry = self.pollQuestionEntries
        }

        if let newPollQuestion = self.newPollQuestion, elementName == "question" {
            self.pollQuestions.append(newPollQuestion)
            self.newPollQuestion = nil
        }

        self.statePollQuestion = .none
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let _ = self.newPollQuestion else { return }

        switch self.statePollQuestion {
        case .id:
            if self.newPollQuestionEntry == nil {
                self.newPollQuestion!.id = string
            }
        case .type:
            self.newPollQuestion!.type = string
        case .text:
            self.newPollQuestion!.text = string
        default:
            break
        }

        switch self.stateEntry {
        case .id:
            if self.newPollQuestionEntry != nil {
                self.newPollQuestionEntry!.id = string
            }
        case .value:
            self.newPollQuestionEntry!.value = string
        case .order:
            self.newPollQuestionEntry!.order = string
        default:
            break
        }
    }
}
