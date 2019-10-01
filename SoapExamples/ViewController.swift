//
//  ViewController.swift
//  SoapExamples
//
//  Created by Denis Islamov on 21/09/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SoapWebServiceDelegate {

    let login : String  = "vg_01";
    let pass : String   = "vg_01";
    let secret : String = "test_secret";

    var soapWebServiceManager : SoapWebServiceManager!

    var token : String = ""
    var userInfo : UserInfo = UserInfo()
    var userGroup : UserGroup = UserGroup()
    var userLessons : [UserLesson] = []

    @IBOutlet weak var myMessage: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        soapWebServiceManager = SoapWebServiceManager(soapWebServiceDelegateRef: self);
    }

    @IBAction func btnClicked(sender: AnyObject) {
        soapWebServiceManager.getToken(login: login, pass: pass, secret: secret)
    }

    @IBAction func SendMessage(_ sender: Any) {
        soapWebServiceManager.sendUserMessage(token: token, eventId: userGroup.eventId, message: myMessage.text!, receiverId: userGroup.contacts[0].personId)
    }

    @IBAction func GetMyMessages(_ sender: Any) {
        soapWebServiceManager.getUserMessages(token: token, id: userGroup.eventId, messageCount: 10, isMy: 1)
    }

    @IBAction func GetMessages(_ sender: Any) {
        soapWebServiceManager.getUserMessages(token: token, id: userGroup.eventId, messageCount: 10, isMy: 0)
    }

    @IBAction func GetMessagesFromPool(_ sender: Any) {
        soapWebServiceManager.getUserMessagesFromPool(token: token, id: userGroup.eventId)
    }

    @IBAction func logoutBtnClicked(sender: AnyObject) {
        soapWebServiceManager.logout(token: token)
    }

    func tokenReceived(value : String) {
        print("token: " + value)
        token = value
        soapWebServiceManager.getUserInfo(token: value)
        soapWebServiceManager.getUserGroup(token: value)
    }

    func userInfoReceived(value : UserInfo) {
        print(value)
        userInfo = value
    }

    func userGroupReceived(value: UserGroup) {
        print(value)
        userGroup = value

        soapWebServiceManager.getUserSchedule(token: token, eventId: userGroup.eventId)
        soapWebServiceManager.getUserMessages(token: token, id: userGroup.eventId)
    }

    func userLessonReceived(value: [UserLesson]) {
        print(value)
        userLessons = value
    }

    func userMessageReceived(value: [Message]) {
        print(value)
    }

    func userInAppTokenReceived(value: String) {
        print(value)
    }
    
    func errorReceived(value : String) {
        print("error: " + value)
    }
}
