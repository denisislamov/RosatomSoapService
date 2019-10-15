//
//  ViewController.swift
//  SoapExamples
//
//  Created by Denis Islamov on 21/09/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import UIKit

class ViewController: UIViewController,
                      SoapServiceManagerDelegate,
                      AuthSoapServiceManagerDelegate,
                      UserInfoSoapServiceManagerDelegate,
                      UserScheduleSoapServiceManagerDelegate,
                      UserMessageSoapServiceManagerDelegate,
                      UserInAppSoapServiceManagerDelegate,
                      TutorEventsSoapServiceManagerDelegate,
                      PollsSoapServiceManagerDelegate,
                      RssNewsManagerDelegate {

    let login : String  = "kmansurov";
    let pass : String   = "hg6Ty23";
    let secret : String = "test_secret";

    var authSoapServiceManager : AuthSoapServiceManager!
    var userInfoSoapServiceManager : UserInfoSoapServiceManager!
    var userScheduleSoapServiceManager : UserScheduleSoapServiceManager!
    var userMessageSoapServiceManager : UserMessageSoapServiceManager!
    var userInAppSoapServiceManager: UserInAppSoapServiceManager!
    var analyticsDataSoapServiceManager : AnalyticsDataSoapServiceManager!
    var tutorEventsSoapServiceManager : TutorEventsSoapServiceManager!
    var pollsSoapServiceManager: PollsSoapServiceManager!

    var rssNewsManager : RssNewsManager!

    var token : String = ""
    var userInfo : UserInfo = UserInfo()
    var userGroup : UserGroup = UserGroup()
    var userLessons : [UserLesson] = []

    @IBOutlet weak var myMessage: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        authSoapServiceManager         = AuthSoapServiceManager        (soapWebServiceDelegateRef: self, soapUrl: RosatomSoapMessages.soapServiceUrl)
        userInfoSoapServiceManager     = UserInfoSoapServiceManager    (soapWebServiceDelegateRef: self, soapUrl: RosatomSoapMessages.soapServiceUrl)
        userScheduleSoapServiceManager = UserScheduleSoapServiceManager(soapWebServiceDelegateRef: self, soapUrl: RosatomSoapMessages.soapServiceUrl)
        userMessageSoapServiceManager  = UserMessageSoapServiceManager (soapWebServiceDelegateRef: self, soapUrl: RosatomSoapMessages.soapServiceUrl)
        userInAppSoapServiceManager    = UserInAppSoapServiceManager   (soapWebServiceDelegateRef: self, soapUrl: RosatomSoapMessages.soapServiceUrl)
        analyticsDataSoapServiceManager = AnalyticsDataSoapServiceManager(soapWebServiceDelegateRef: self,
                                                                          soapUrl: RosatomSoapMessages.soapServiceUrl)
        tutorEventsSoapServiceManager = TutorEventsSoapServiceManager(soapWebServiceDelegateRef: self, soapUrl: RosatomSoapMessages.soapServiceUrl)
        pollsSoapServiceManager = PollsSoapServiceManager(soapWebServiceDelegateRef: self, soapUrl: RosatomSoapMessages.soapServiceUrl)
        rssNewsManager = RssNewsManager(rssNewsManagerDelegateRef : self)
    }

    @IBAction func btnClicked(sender: AnyObject) {
        authSoapServiceManager.getToken(login: login, pass: pass, secret: secret)
        rssNewsManager.startParsingWithContentsOfURL()
    }

    @IBAction func SendMessage(_ sender: Any) {
        userMessageSoapServiceManager.sendUserMessage(token: token, eventId: userGroup.eventId, message: myMessage.text!, receiverId: userGroup.contacts[0].personId)
    }

    @IBAction func GetMyMessages(_ sender: Any) {
        userMessageSoapServiceManager.getUserMessages(token: token, id: userGroup.eventId, messageCount: 10, isMy: 1)
    }

    @IBAction func GetMessages(_ sender: Any) {
        userMessageSoapServiceManager.getUserMessages(token: token, id: userGroup.eventId, messageCount: 10, isMy: 0)
    }

    @IBAction func GetMessagesFromPool(_ sender: Any) {
        userMessageSoapServiceManager.getUserMessagesFromPool(token: token, id: userGroup.eventId)
    }

    @IBAction func logoutBtnClicked(sender: AnyObject) {
        authSoapServiceManager.logout(token: token)
    }

    @IBAction func SendInAppToken(_ sender: Any) {
        userInAppSoapServiceManager.sendInAppUserToken(token: token, inAppToken: "abcd12345")
    }

    @IBAction func GetInAppToken(_ sender: Any) {
        userInAppSoapServiceManager.getInAppUserToken(token: token)
    }

    @IBAction func SendAnalyticsData(_ sender: Any) {
        analyticsDataSoapServiceManager.sendAnalyticsData(token: token, data: "1,2,3,4,5")
    }

    @IBAction func GetTutorEvents(_ sender: Any) {
        tutorEventsSoapServiceManager.getTurorEvents(token: token)
        pollsSoapServiceManager.getTutorPolls(token: token)
    }

    func tokenReceived(value : String) {
        print("token: " + value)
        token = value
        print(authSoapServiceManager.parseDecodeToken(input: token))
        userInfoSoapServiceManager.getUserInfo(token: value)
        userInfoSoapServiceManager.getUserGroup(token: value)
    }

    func tokenInfoReceived(value: TokenInfo) {
        print("\(value)")
    }

    func userInfoReceived(value : UserInfo) {
        print(value)
        userInfo = value
    }

    func userGroupReceived(value: UserGroup) {
        print(value)
        userGroup = value

        userScheduleSoapServiceManager.getUserSchedule(token: token, eventId: userGroup.eventId)
        userMessageSoapServiceManager.getUserMessages(token: token, id: userGroup.eventId)
    }

    func userLessonsReceived(value: [UserLesson]) {
        print(value)
        userLessons = value
    }

    func userMessageReceived(value: [Message]) {
        print(value)
    }

    func userInAppTokenReceived(value: String) {
        print(value)
    }

    func tutorEventsReceived(value: [TutorEvent]) {
        print(value)
    }

    func errorReceived(value : String) {
        print("error: " + value)
    }

    func tutorPollsReceived(value: [TutorPoll]) {
        print(value)
    }


    func rssNewsReceived(value: [RssNewsArticle]) {
        print(value)
    }

    func rssErrorReceived(value: String) {
        print(value)
    }
}
