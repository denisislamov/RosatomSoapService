//
//  UserGroupParserDelegate.swift
//  SoapExamples
//
//  Created by Denis Islamov on 26/09/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

class UserGroupParserDelegate: NSObject, XMLParserDelegate {
    var userGroup : UserGroup = UserGroup()
    var contacts : [Contact] = []
    var newContact : Contact? = nil

    enum StateUserGroup { case none, eventId, name, code, startDate, finishDate, status, personNum, place }
    enum StateContact { case none, personId, name, type }

    var stateUserGroup : StateUserGroup = .none
    var stateContact : StateContact = .none

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "event_id":
            self.stateUserGroup = .eventId
        case "name":
            if self.newContact != nil {
                self.stateContact = .name
            } else {
                self.stateUserGroup = .name
            }
        case "code":
            self.stateUserGroup = .code
        case "start_date":
            self.stateUserGroup = .startDate
        case "finish_date":
            self.stateUserGroup = .finishDate
        case "status":
            self.stateUserGroup = .status
        case "person_num":
            self.stateUserGroup = .personNum
        case "place":
            self.stateUserGroup = .place
        case "contact" :
            self.newContact = Contact()
            self.stateContact = .none
        case "person_id":
            self.stateContact = .personId
        case "type":
            self.stateContact = .type
        default:
            self.stateContact = .none
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let newContact = self.newContact, elementName == "contact" {
            self.contacts.append(newContact)
            self.newContact = nil
        }
        self.stateContact = .none

        if elementName == "contacts" {
            self.userGroup.contacts = contacts
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if string == "\n" {
            return
        }

        switch self.stateUserGroup {
        case .eventId:
            self.userGroup.eventId = string
        case .name:
            self.userGroup.name = string
        case .code:
            self.userGroup.code = string
        case .startDate:
            self.userGroup.startDate = string
        case .finishDate:
            self.userGroup.finishDate = string
        case .status:
            self.userGroup.status = string
        case .personNum:
            self.userGroup.personNum = string
        case .place:
            self.userGroup.place = string
        default:
            break
        }

        guard let _ = self.newContact else { return }

        switch self.stateContact {
        case .personId:
            self.newContact!.personId = string
        case .name:
            self.newContact!.name = string
        case .type:
            self.newContact!.type = string
        default:
            break
        }
    }
}
