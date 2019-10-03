//
//  AnalyticsDataSoapServiceDelegate.swift
//  SoapExamples
//
//  Created by Denis Islamov on 03/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

class AnalyticsDataSoapServiceManager : SoapServiceManager {
    public func sendAnalyticsData(token: String, data: String) {
        let soapAuthMessage : String = RosatomSoapMessages.sendAnalyticsData(token: token, data: data)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingSendAnalyticsDataRespond)
        })
    }

    private func parsingSendAnalyticsDataRespond(input: String) -> SoapServiceResult<String> {
        if input.contains("SetLogResponse") {
            return SoapServiceResult.Success("Success send analytics data")
        }

        let errorDescription = errorHandler(value: input)
        soapServiceManagerDelegate?.errorReceived(value: errorDescription)
        return SoapServiceResult.Failure(errorDescription)
    }

}
