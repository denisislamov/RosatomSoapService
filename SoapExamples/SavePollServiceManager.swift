//
//  SavePollServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 16/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

class SavePollServiceManager : SoapServiceManager {
    public func savePoll(token: String, pollProcedureId: String, data: String) {
        let soapAuthMessage : String = RosatomSoapMessages.savePull(token: token, pollProcedureId: pollProcedureId, data: data)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.savePollParsing)
        })
    }

    private func savePollParsing(input: String) -> SoapServiceResult<String> {
        if input.contains("<SavePollResponse>") {
            return SoapServiceResult.Success("Success save poll")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}
