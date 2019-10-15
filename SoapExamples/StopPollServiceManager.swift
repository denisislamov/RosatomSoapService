//
//  StopPollServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 16/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

class StopPollServiceManager : SoapServiceManager {
    public func stopPoll(token: String, pollProcedureId: String) {
        let soapAuthMessage : String = RosatomSoapMessages.stopPull(token: token, pollProcedureId: pollProcedureId)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.stopPollParsing)
        })
    }

    private func stopPollParsing(input: String) -> SoapServiceResult<String> {
        if input.contains("<StopPollResponse>") {
            return SoapServiceResult.Success("Success stop poll")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}
