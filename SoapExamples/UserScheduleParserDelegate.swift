//
//  UserGroupParserDelegate.swift
//  SoapExamples
//
//  Created by Denis Islamov on 26/09/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

class UserScheduleParserDelegate: NSObject, XMLParserDelegate {
    var userLessons : [UserLesson] = []
    var newUserLesson : UserLesson? = nil

    enum StateUserLessons { case none, id, name, room, lessonDate, startTime, finishTime, lector, form }

    var stateUserLessons : StateUserLessons = .none

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
        case "lesson" :
            self.newUserLesson = UserLesson()
            self.stateUserLessons = .none
        case "id":
            self.stateUserLessons = .id
        case "name":
            self.stateUserLessons = .name
        case "room":
            self.stateUserLessons = .room
        case "lesson_date":
            self.stateUserLessons = .lessonDate
        case "start_time":
            self.stateUserLessons = .startTime
        case "finish_time":
            self.stateUserLessons = .finishTime
        case "lector":
            self.stateUserLessons = .lector
        case "form":
            self.stateUserLessons = .form
        default:
            self.stateUserLessons = .none
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let newLesson = self.newUserLesson, elementName == "lesson" {
            self.userLessons.append(newLesson)
            self.newUserLesson = nil
        }
        self.stateUserLessons = .none
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let _ = self.newUserLesson else { return }

        switch self.stateUserLessons {
        case .id:
            self.newUserLesson!.id = string
        case .name:
            self.newUserLesson!.name = string
        case .room:
            self.newUserLesson!.room = string
        case .lessonDate:
            self.newUserLesson!.lessonDate = string
        case .startTime:
            self.newUserLesson!.startTime = string
        case .finishTime:
            self.newUserLesson!.finishTime = string
        case .lector:
            self.newUserLesson!.lector = string
        case .form:
            self.newUserLesson!.form = string
        default:
            break
        }
    }
}
