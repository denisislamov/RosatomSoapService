//
//  GetPollResultSoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 18/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol GetPollResultServiceManagerDelegate : SoapServiceManagerDelegate {
    func getPollReceived(value: [PollQuestionResult])
}

class GetPollResultSoapServiceManager : SoapServiceManager {
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

            let delegate = GetPollResultDelegate()
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                if let getPollServiceManagerDelegate =  soapServiceManagerDelegate as? GetPollResultServiceManagerDelegate {
                    getPollServiceManagerDelegate.getPollReceived(value: delegate.pollQuestions)
                    return SoapServiceResult.Success("Success get poll result")
                }
            }
        } else if input.contains("GetPollResultResponse") {
            return SoapServiceResult.Success("Can't get poll result for this user")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}

class GetPollResultDelegate : NSObject, XMLParserDelegate {
    var pollQuestions : [PollQuestionResult] = []
    var newPollQuestion : PollQuestionResult? = nil

    var pollQuestionEntries : [PollQuestionResultEntry] = []
    var newPollQuestionEntry : PollQuestionResultEntry? = nil

    enum StatePollQuestion { case none, id, text }
    var statePollQuestion : StatePollQuestion = .none

    enum StateEntry { case none, id, value, order, answerNum }
    var stateEntry : StateEntry = .none

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "question":
            self.newPollQuestion = PollQuestionResult()
            self.statePollQuestion = .none
        case "id":
            if self.newPollQuestionEntry == nil {
                self.statePollQuestion = .id
            } else {
                self.stateEntry = .id
            }
        case "text":
            self.statePollQuestion = .text
        case "entry":
           self.newPollQuestionEntry = PollQuestionResultEntry()
           self.stateEntry = .none
        case "value":
           self.stateEntry = .value
        case "order":
           self.stateEntry = .order
        case "answer_num":
            self.stateEntry = .answerNum
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
            self.newPollQuestion!.pollQuestionResultEntries = self.pollQuestionEntries
        }

        if let newPollQuestion = self.newPollQuestion, elementName == "question" {
            self.pollQuestions.append(newPollQuestion)
            self.pollQuestionEntries = []
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
        case .answerNum:
            self.newPollQuestionEntry!.answerNum = string
        default:
            break
        }
    }
}

