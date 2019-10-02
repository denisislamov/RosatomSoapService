//
// Created by Denis Islamov on 21/09/2019.
// Copyright (c) 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

enum SoapWebServiceResult<T> {
    case Success(T)
    case Failure(T)
}

protocol SoapWebServiceDelegate : class {
    func tokenReceived(value : String)
    func userInfoReceived(value : UserInfo)
    func userGroupReceived(value: UserGroup)
    func userLessonReceived(value: [UserLesson])
    func userMessageReceived(value: [Message])
    func userInAppTokenReceived(value: String)

    func errorReceived(value : String)
}

class SoapWebServiceManager {
    private weak var soapWebServiceDelegate : SoapWebServiceDelegate?

    public init(soapWebServiceDelegateRef : SoapWebServiceDelegate) {
        soapWebServiceDelegate = soapWebServiceDelegateRef
    }

    public func getToken(login : String, pass : String, secret : String) {
        let soapAuthMessage : String = RosatomSoapMessages.auth(login: login, pass: pass, secret: secret)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingXmlToken)
        })
    }

    private func parsingXmlToken(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<token>") {
            soapWebServiceDelegate?.tokenReceived(value: input.slice(from: "<token>", to: "</token>")!)
            return SoapWebServiceResult.Success("Success get user token")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return  SoapWebServiceResult.Failure(errorDescription)
    }

    public func logout(token: String) {
        let soapAuthMessage : String = RosatomSoapMessages.logout(token: token)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.logoutRespond)
        })
    }

    private func logoutRespond(input: String) -> SoapWebServiceResult<String> {
        if input.contains("LogoutResponse") {
            return SoapWebServiceResult.Success("Success logout")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return  SoapWebServiceResult.Failure(errorDescription)
    }

    public func getUserInfo(token : String) {
        let soapAuthMessage : String = RosatomSoapMessages.userInfo(token: token)
        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingXmlUserInfo)
        })
    }

    private func parsingXmlUserInfo(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<fullname>") {
            var userInfo = UserInfo()
            userInfo.fullName = input.slice(from: "<fullname>", to: "</fullname>")!
            userInfo.position = input.slice(from: "<position>", to: "</position>")!
            userInfo.org      = input.slice(from: "<org>", to: "</org>")!
            userInfo.email    = input.slice(from: "<email>", to: "</email>")!

            soapWebServiceDelegate?.userInfoReceived(value: userInfo)
            return SoapWebServiceResult.Success("Success get user info")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return  SoapWebServiceResult.Failure(errorDescription)
    }

    public func getUserGroup(token : String) {
        let soapAuthMessage : String = RosatomSoapMessages.userGroupInfo(token: token)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingUserGroup)
        })
    }

    private func parsingUserGroup(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<event>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = UserGroupParserDelegate()
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                soapWebServiceDelegate?.userGroupReceived(value: delegate.userGroup)
                return SoapWebServiceResult.Success("Success get user group info")
            }
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }

    public func getUserSchedule(token: String, eventId: String) {
        let soapAuthMessage : String = RosatomSoapMessages.userSchedule(token: token, eventId: eventId)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingUserSchedule)
        })
    }

    private func parsingUserSchedule(input: String) -> SoapWebServiceResult<String> {
       if input.contains("<lessons>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = UserScheduleParserDelegate()
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                soapWebServiceDelegate?.userLessonReceived(value: delegate.userLessons)
                return SoapWebServiceResult.Success("Success get user schedule info")
            }
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }

    public func getUserMessages(token: String, id: String, messageCount: Int = 10, isMy: Int = 0) {
        let soapAuthMessage : String = RosatomSoapMessages.userMessages(token: token, eventId: id,  messageCount: messageCount, isMy : isMy)

        sendRequest(requests: soapAuthMessage, completion: { result in
            if isMy == 0 {
                self.soapRequestСompletion(result: result, parsingFunc: self.parsingUserMessages)
            } else {
                self.soapRequestСompletion(result: result, parsingFunc: self.parsingMyUserMessages)
            }
        })
    }

    public func getUserMessagesFromPool(token: String, id: String) {
        let soapAuthMessage : String = RosatomSoapMessages.userMessagesFromPool(token: token, eventId: id)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingUserMessages)
        })
    }

    private func parsingUserMessages(input: String) -> SoapWebServiceResult<String> {
        print(input)
        if input.contains("<messages>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = UserMessageParserDelegate(isMyMessages: "0")
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                soapWebServiceDelegate?.userMessageReceived(value: delegate.userMessages)
                return SoapWebServiceResult.Success("Success get user messages")
            }
        } else if input.contains("GetMsgsResponse") || input.contains("GetMsgFromPoolResponse") {
            return SoapWebServiceResult.Success("No messages for this user or event")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }

    private func parsingMyUserMessages(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<messages>") {
            var result = input.removeEmptyLines();
            result = result?.slice(from: "Optional(", to: ")")!

            let delegate = UserMessageParserDelegate(isMyMessages: "1")
            if xmlParserRespond(input: result!, xmlParserDelegate: delegate) {
                soapWebServiceDelegate?.userMessageReceived(value: delegate.userMessages)
                return SoapWebServiceResult.Success("Success get user messages")
            }
        } else if input.contains("GetMsgsResponse") {
            return SoapWebServiceResult.Success("No messages for this user or event")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }

    public func sendUserMessage(token: String, eventId: String, message: String, receiverId: String) {
        let soapAuthMessage : String = RosatomSoapMessages.sendUserMessage(token: token, eventId: eventId, message: message, receiverId: receiverId)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingSendUserMessageRespond)
        })
    }

    private func parsingSendUserMessageRespond(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<status>") {
            return SoapWebServiceResult.Success("Success send user message")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }

    public func sendInAppUserToken(token: String, inAppToken: String) {
         let soapAuthMessage : String = RosatomSoapMessages.sendInAppUserToken(token: token, inAppToken: inAppToken)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingSendInAppUserTokenRespond)
        })
    }

    private func parsingSendInAppUserTokenRespond(input: String) -> SoapWebServiceResult<String> {
        if input.contains("SetPushTokenResponse") {
            return SoapWebServiceResult.Success("Success send inApp token")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }

    public func getInAppUserToken(token: String) {
        let soapAuthMessage : String = RosatomSoapMessages.getInAppUserToken(token: token)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingInAppUserToken)
        })
    }

    private func parsingInAppUserToken(input: String) -> SoapWebServiceResult<String> {
        if input.contains("<token>") {
            soapWebServiceDelegate?.userInAppTokenReceived(value: input.slice(from: "<token>", to: "</token>")!)
            return SoapWebServiceResult.Success("Success get user inApp token")
        } else if input.contains("<GetPushTokenResponse>") {
            return SoapWebServiceResult.Success("No inApp token for this user")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }

    public func sendAnalyticsData(token: String, data: String) {
        let soapAuthMessage : String = RosatomSoapMessages.sendAnalyticsData(token: token, data: data)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingSendAnalyticsDataRespond)
        })
    }

    private func parsingSendAnalyticsDataRespond(input: String) -> SoapWebServiceResult<String> {
        if input.contains("SetLogResponse") {
            return SoapWebServiceResult.Success("Success send analytics data")
        }

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }

    private func getTutorEvents(token: String) {
        let soapAuthMessage : String = RosatomSoapMessages.getTutorEvents(token: token)

        sendRequest(requests : soapAuthMessage, completion: { result in
            self.soapRequestСompletion(result: result, parsingFunc: self.parsingTutorEvents)
        })
    }

    private func parsingTutorEvents(input: String) -> SoapWebServiceResult<String> {
        print(input)

        let errorDescription = errorHandler(value: input)
        soapWebServiceDelegate?.errorReceived(value: errorDescription)
        return SoapWebServiceResult.Failure(errorDescription)
    }



    private func xmlParserRespond(input: String, xmlParserDelegate : XMLParserDelegate ) -> Bool {
        let xmlParser = XMLParser(data: (input.data(using: .utf16))!)
        xmlParser.delegate = xmlParserDelegate

        return xmlParser.parse()
    }

    private func soapRequestСompletion(result: SoapWebServiceResult<String>, parsingFunc:(_:String) -> SoapWebServiceResult<String>) -> Void {
        switch result {
        case SoapWebServiceResult.Success(let response):
            parsingFunc(response);
            break
        case SoapWebServiceResult.Failure(let error):
            self.soapWebServiceDelegate?.errorReceived(value: error)
            break
        }
    }

    // TODO - move xml parser to different function
    private func sendRequest(requests : String, completion: @escaping (SoapWebServiceResult<String>) -> Void) {
        let lobjRequest = NSMutableURLRequest(url: NSURL(string: RosatomSoapMessages.soapServiceUrl)! as URL)
        let session = URLSession.shared

        lobjRequest.httpMethod = "POST"
        lobjRequest.httpBody = requests.data(using: .utf8)
        lobjRequest.addValue("text/xml; charset=utf-8", forHTTPHeaderField: "Content-Type")
        lobjRequest.addValue(String(requests.count), forHTTPHeaderField: "Content-Length")
        lobjRequest.addValue("http://www.cgsapi.com/GetSystemStatus", forHTTPHeaderField: "SOAPAction")

        let task = session.dataTask(with: lobjRequest as URLRequest, completionHandler: { (data, response, error) -> Void in
            let strData = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)

            if error != nil {
                completion(SoapWebServiceResult.Failure(error.debugDescription))
            } else {
                completion(SoapWebServiceResult.Success(String(describing: strData)))
            }
        })
        task.resume()
    }

    private func errorHandler(value: String) -> String {
        if value.contains("<soap:Fault>") {
            let errorMsg = value.slice(from: "<faultstring>", to: "</faultstring>")!
            return errorMsg
        }

        return "Unknown error"
    }
}

extension String {
    func slice(from: String, to: String) -> String? {
        (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }
    }

    func removeEmptyLines() -> String? {
        let lines = self.split { $0.isNewline }
        return lines.joined(separator: "\n")
    }
}
