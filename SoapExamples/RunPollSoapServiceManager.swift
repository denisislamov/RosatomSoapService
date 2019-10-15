//
//  RunPollSoapServiceManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 12/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

// TODO - CHANGE TO RUNPOLL

protocol RunPollSoapServiceManagerDelegate : SoapServiceManagerDelegate {
    func runPollReceived(value: [RunPollData])
}

class RunPollServiceManager : SoapServiceManager {
    public func runPolls(token: String, eventId: String) {
        let soapAuthMessage : String = RosatomSoapMessages.runPull(token: token, eventId: eventId)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.runPollsParsing)
        })
    }

    private func runPollsParsing(input: String) -> SoapServiceResult<String> {
        if input.contains("<RunPollResponse>") {
            var runPollData = RunPollData()
            runPollData.all             = input.slice(from: "<all>", to: "</all>")!
            runPollData.assigned        = input.slice(from: "<assigned>", to: "</assigned>")!
            runPollData.pollProcedureId = input.slice(from: "<poll_procedure_id>", to: "</poll_procedure_id>")!

            if let runPollSoapServiceManagerDelegate =  soapServiceManagerDelegate as? RunPollSoapServiceManagerDelegate {
                runPollSoapServiceManagerDelegate.runPollReceived(value: [runPollData])
                return SoapServiceResult.Success("Success run poll")
            }
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }
}
