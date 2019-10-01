//
//  UserMessageParserDelegate.swift
//  SoapExamples
//
//  Created by Denis Islamov on 30/09/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

class UserMessageParserDelegate : NSObject, XMLParserDelegate {
    var userMessages : [Message] = []
    var newUserMessage : Message? = nil

    public var isMy : String

    init(isMyMessages : String) {
        isMy = isMyMessages
    }

    enum StateUserMessage {case none, fromPersonId, toPersonId, text, date, isNew}
    var stateUserMessage : StateUserMessage = .none

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "message":
            self.newUserMessage = Message()
            self.newUserMessage!.isMy = isMy
            self.stateUserMessage = .none
        case "is_new":
            self.stateUserMessage = .isNew
        case "from_person_id":
            self.stateUserMessage = .fromPersonId
        case "to_person_id":
            self.stateUserMessage = .toPersonId
        case "text":
            self.stateUserMessage = .text
        case "message_date":
            self.stateUserMessage = .date
        default:
            self.stateUserMessage = .none
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let newMessage = self.newUserMessage, elementName == "message" {
            self.userMessages.append(newMessage)
            self.newUserMessage = nil
        }

        self.stateUserMessage = .none
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let _ = self.newUserMessage else { return }

        switch self.stateUserMessage {
        case .isNew:
            self.newUserMessage!.isNew = string
        case .fromPersonId:
            self.newUserMessage!.fromPersonId = string
        case .toPersonId:
            self.newUserMessage!.toPersonId = string
        case .text:
            self.newUserMessage!.text = string
        case .date:
            self.newUserMessage!.date = string
        default:
            break
        }
    }
}
