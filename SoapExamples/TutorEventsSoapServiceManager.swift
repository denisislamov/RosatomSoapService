//
//  TutorEventsSoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 04/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol TutorEventsSoapServiceManagerDelegate : SoapServiceManagerDelegate {
    func tutorEventsReceived(value: [TutorEvent])
}

class TutorEventsSoapServiceManager : SoapServiceManager {
    public func getTurorEvents(token : String) {
        let soapAuthMessage : String = RosatomSoapMessages.getTutorEvents(token: token)
        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingXmlTurorEvents)
        })
    }

    private func parsingXmlTurorEvents(input: String) -> SoapServiceResult<String> {
        if input.contains("events") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = TutorEventsParserDelegate()
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                if let tutorEventsSoapServiceManagerDelegate =  soapServiceManagerDelegate as? TutorEventsSoapServiceManagerDelegate {
                    tutorEventsSoapServiceManagerDelegate.tutorEventsReceived(value: delegate.tutorEvents)
                   return SoapServiceResult.Success("Success get tutor events")
                }
            }
        } else if input.contains("GetTutorEventsResponse") {
            return SoapServiceResult.Success("No tutor events for this user")
        }
        
        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}
