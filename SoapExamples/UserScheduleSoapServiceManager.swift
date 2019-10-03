//
//  UserScheduleSoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 03/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol UserScheduleSoapServiceManagerDelegate : SoapServiceManagerDelegate {
    func userLessonsReceived(value: [UserLesson])
}

class UserScheduleSoapServiceManager : SoapServiceManager {
    public func getUserSchedule(token: String, eventId: String) {
        let soapAuthMessage : String = RosatomSoapMessages.userSchedule(token: token, eventId: eventId)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingUserSchedule)
        })
    }

    private func parsingUserSchedule(input: String) -> SoapServiceResult<String> {
       if input.contains("<lessons>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = UserScheduleParserDelegate()
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                if let userScheduleSoapServiceManagerDelegate =  soapServiceManagerDelegate as? UserScheduleSoapServiceManagerDelegate {
                    userScheduleSoapServiceManagerDelegate.userLessonsReceived(value: delegate.userLessons)
                    return SoapServiceResult.Success("Success get user schedule info")
                }
            }
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}
