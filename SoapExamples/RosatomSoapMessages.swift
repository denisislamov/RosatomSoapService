//
//  SoapMessages.swift
//  SoapExamples
//
//  Created by Denis Islamov on 24/09/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

class RosatomSoapMessages {
    public static  let soapServiceUrl : String = "https://sdo.rosatomtech.ru/sdo-cicet/service/vgService.html"

    public static func auth(login: String, pass : String, secret : String) -> String {
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n                <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n                    <soap:Body>\n                    <Auth xmlns:ns1=\"http://sdo-test.scicet.local/\" username=\"\(login)\" password=\"\(pass)\" secret=\"\(secret)\"/>\n                    </soap:Body>\n                </soap:Envelope>"
    }

    public static func logout(token: String) -> String {
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n                <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n                    <soapenv:Header>\n                  <sdo:Token>\n                     <sdo:authtoken>\(token)</sdo:authtoken>\n                  </sdo:Token>\n                   </soapenv:Header>\n                   <soapenv:Body>\n                      <sdo:Logout>?</sdo:Logout>\n                   </soapenv:Body>\n            </soapenv:Envelope>"
    }

    public static func userInfo(token : String) -> String {
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n                <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n                    <soapenv:Header>\n                        <sdo:Token>\n                            <sdo:authtoken>\(token)</sdo:authtoken>\n                    </sdo:Token>\n                    </soapenv:Header>\n                    <soapenv:Body>\n                        <sdo:UserInfo></sdo:UserInfo>\n                    </soapenv:Body>\n                </soapenv:Envelope>"
    }

    public static func userGroupInfo(token : String) -> String {
        "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n   <soapenv:Header>\n      <sdo:Token>\n         <sdo:authtoken>\(token)</sdo:authtoken>\n      </sdo:Token>\n   </soapenv:Header>\n   <soapenv:Body>\n      <sdo:GetCurrentEvent>?</sdo:GetCurrentEvent>\n   </soapenv:Body>\n</soapenv:Envelope>"
    }

    public static func userSchedule(token : String, eventId: String) -> String {
        "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n   <soapenv:Header>\n      <sdo:Token>\n         <sdo:authtoken>\(token)</sdo:authtoken>\n      </sdo:Token>\n   </soapenv:Header>\n   <soapenv:Body>\n      <sdo:GetEventSchedule>\n         <sdo:event_id>\(eventId)</sdo:event_id>\n      </sdo:GetEventSchedule>\n   </soapenv:Body>\n</soapenv:Envelope>"
    }

    public static func userMessages(token: String, eventId: String, messageCount: Int = 10, isMy : Int = 0) -> String {
        "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n   <soapenv:Header>\n      <sdo:Token>\n         <sdo:authtoken>\(token)</sdo:authtoken>\n      </sdo:Token>\n   </soapenv:Header>\n   <soapenv:Body>\n      <sdo:GetMsgs>\n         <sdo:msg_num>\(messageCount)</sdo:msg_num>\n         <sdo:event_id>\(eventId)</sdo:event_id>\n         <sdo:is_my>\(isMy)</sdo:is_my>\n      </sdo:GetMsgs>\n   </soapenv:Body>\n</soapenv:Envelope>"
    }

    public static func userMessagesFromPool(token: String, eventId: String) -> String {
        "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n   <soapenv:Header>\n      <sdo:Token>\n         <sdo:authtoken>\(token)</sdo:authtoken>\n      </sdo:Token>\n   </soapenv:Header>\n   <soapenv:Body>\n      <sdo:GetMsgFromPool>\n         <sdo:event_id>\(eventId)</sdo:event_id> --ID группы\n      </sdo:GetMsgFromPool>\n   </soapenv:Body>\n</soapenv:Envelope>"
    }

    public static func sendUserMessage(token: String, eventId: String , message: String , receiverId: String) -> String {
        "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n   <soapenv:Header>\n      <sdo:Token>\n         <sdo:authtoken>\(token)</sdo:authtoken>\n      </sdo:Token>\n   </soapenv:Header>\n   <soapenv:Body>\n      <sdo:SendMsgs>\n         <sdo:event_id>\(eventId)</sdo:event_id>\n         <sdo:message><![CDATA[\(message)]]></sdo:message>\n         <sdo:to_person_id>\(receiverId)</sdo:to_person_id>\n      </sdo:SendMsgs>\n   </soapenv:Body>\n</soapenv:Envelope>"
    }
}
