//
//  TutorEventsParserDelegate.swift
//  SoapExamples
//
//  Created by Denis Islamov on 08/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

class TutorEventsParserDelegate : NSObject, XMLParserDelegate {
    var tutorEvents : [TutorEvent] = []
    var newTutorEvent : TutorEvent? = nil

    enum StateTutorEvents { case none, id, name, code, startDate, finishDate, status, personNum, place }
    var stateTutorEvents : StateTutorEvents = .none

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "event":
            self.newTutorEvent = TutorEvent()
            self.stateTutorEvents = .none
        case "id":
            self.stateTutorEvents = .id
        case "name":
            self.stateTutorEvents = .name
        case "code":
            self.stateTutorEvents = .code
        case "start_date":
            self.stateTutorEvents = .startDate
        case "finish_date":
            self.stateTutorEvents = .finishDate
        case "status":
            self.stateTutorEvents = .status
        case "person_num":
            self.stateTutorEvents = .personNum
        case "place":
            self.stateTutorEvents = .place
        default:
            self.stateTutorEvents = .none
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let newTutorEvent = self.newTutorEvent, elementName == "event" {
            self.tutorEvents.append(newTutorEvent)
            self.newTutorEvent = nil
        }

        self.stateTutorEvents = .none
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let _ = self.newTutorEvent else { return }

        switch self.stateTutorEvents {
        case .id:
            self.newTutorEvent!.id = string
        case .name:
            self.newTutorEvent!.name = string
        case .code:
            self.newTutorEvent!.code = string
        case .startDate:
            self.newTutorEvent!.startDate = string
        case .finishDate:
            self.newTutorEvent!.finishDate = string
        case .status:
            self.newTutorEvent!.status = string
        case .personNum:
            self.newTutorEvent!.personNum = string
        case .place:
            self.newTutorEvent!.place = string
        default:
            break
        }
    }
}
