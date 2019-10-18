//
// Created by Denis Islamov on 22/09/2019.
// Copyright (c) 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

struct TokenInfo {
    public var tokenId : String = ""
    public var personId : String = ""
    public var expiredDate : String = ""
    public var roles : String = ""
}

struct UserInfo {
    public var fullName : String = ""
    public var position : String = ""
    public var org : String = ""
    public var email : String = ""
}

struct UserGroup {
    public var eventId : String = ""
    public var name : String = ""
    public var code : String = ""

    public var startDate : String = ""
    public var finishDate : String = ""

    public var status: String = ""
    public var personNum : String = ""
    public var place : String = ""

    public var contacts : [Contact] = []
}

struct Contact {
    public var personId : String = ""
    public var name : String = ""
    public var type : String = ""
}

struct UserLesson {
    public var id : String = ""
    public var name : String = ""
    public var room : String = ""

    public var lessonDate : String = ""
    public var startTime : String = ""
    public var finishTime : String = ""

    public var lector : String = ""
    public var form : String = ""
}

struct Message {
    public var fromPersonId : String = ""
    public var toPersonId : String = ""
    public var text : String = ""
    public var date : String = ""
    public var isNew : String = ""
    public var isMy : String = ""
}

struct TutorEvent {
    public var id : String = ""
    public var name : String = ""
    public var code : String = ""
    public var startDate : String = ""
    public var finishDate : String = ""
    public var status : String = ""
    public var personNum : String = ""
    public var place : String = ""
}

struct RssNewsArticle {
    public var title : String = ""
    public var link : String = ""
    public var pubDate : String = ""
    public var imageUrl : String = ""
}

struct TutorPoll {
    public var id : String = ""
    public var code : String = ""
    public var name : String = ""
}

struct RunPollData {
    public var all : String = ""
    public var assigned : String = ""
    public var pollProcedureId : String = ""
}

struct PollProcedureData {
    public var id : String = ""
    public var code : String = ""
    public var name : String = ""
}

struct PollQuestion {
    public var id : String = ""
    public var type : String = ""
    public var text : String = ""

    public var pollQuestionEntries : [PollQuestionEntry] = []

    public var answer : String = ""
    public var isAnswered : String = ""
}

struct PollQuestionEntry {
    public var id : String = ""
    public var value : String = ""
    public var order : String = ""
}


struct PollQuestionResult {
    public var id : String = ""
    public var text : String = ""

    public var pollQuestionResultEntries : [PollQuestionResultEntry] = []
}

struct PollQuestionResultEntry {
    public var id : String = ""
    public var value : String = ""
    public var order : String = ""
    public var answerNum : String = ""
}
