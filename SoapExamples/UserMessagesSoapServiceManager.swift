//
//  UserMessagesSoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 03/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol UserMessageSoapServiceManagerDelegate : SoapServiceManagerDelegate {
    func userMessageReceived(value: [Message])
}

class UserMessageSoapServiceManager : SoapServiceManager {
    public func getUserMessages(token: String, id: String, messageCount: Int = 10, isMy: Int = 0) {
        let soapAuthMessage : String = RosatomSoapMessages.userMessages(token: token, eventId: id,  messageCount: messageCount, isMy : isMy)

        sendRequest(requests: soapAuthMessage, completion: { result in
            if isMy == 0 {
                self.soapRequestСompletion(result: result, parsingFunc: self.parsingUserMessages)
            } else {
                self.soapRequestСompletion(result: result, parsingFunc: self.parsingMyUserMessages)
            }
        })
    }

    public func getUserMessagesFromPool(token: String, id: String) {
        let soapAuthMessage : String = RosatomSoapMessages.userMessagesFromPool(token: token, eventId: id)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingUserMessages)
        })
    }

    private func parsingUserMessages(input: String) -> SoapServiceResult<String> {
        print(input)
        if input.contains("<messages>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = UserMessageParserDelegate(isMyMessages: "0")
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                if let userMessageSoapServiceManagerDelegate =  soapServiceManagerDelegate as? UserMessageSoapServiceManagerDelegate {
                    userMessageSoapServiceManagerDelegate.userMessageReceived(value: delegate.userMessages)
                    return SoapServiceResult.Success("Success get user messages")
                }
            }
        } else if input.contains("GetMsgsResponse") || input.contains("GetMsgFromPoolResponse") {
            return SoapServiceResult.Success("No messages for this user or event")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }

    private func parsingMyUserMessages(input: String) -> SoapServiceResult<String> {
        if input.contains("<messages>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = UserMessageParserDelegate(isMyMessages: "1")
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                if let userMessageSoapServiceManagerDelegate =  soapServiceManagerDelegate as? UserMessageSoapServiceManagerDelegate {
                    userMessageSoapServiceManagerDelegate.userMessageReceived(value: delegate.userMessages)
                    return SoapServiceResult.Success("Success get user messages")
                }
            }
        } else if input.contains("GetMsgsResponse") {
            return SoapServiceResult.Success("No messages for this user or event")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }

    public func sendUserMessage(token: String, eventId: String, message: String, receiverId: String) {
        let soapAuthMessage : String = RosatomSoapMessages.sendUserMessage(token: token, eventId: eventId, message: message, receiverId: receiverId)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingSendUserMessageRespond)
        })
    }

    private func parsingSendUserMessageRespond(input: String) -> SoapServiceResult<String> {
        if input.contains("<status>") {
            return SoapServiceResult.Success("Success send user message")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }

}
