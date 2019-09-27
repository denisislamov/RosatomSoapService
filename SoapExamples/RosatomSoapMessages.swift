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

    public static func auth(_ login: String, _ pass : String, _ secret : String) -> String {
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n                <soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n                    <soap:Body>\n                    <Auth xmlns:ns1=\"http://sdo-test.scicet.local/\" username=\"\(login)\" password=\"\(pass)\" secret=\"\(secret)\"/>\n                    </soap:Body>\n                </soap:Envelope>"
    }

    public static func logout(_ token: String) -> String {
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n                <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n                    <soapenv:Header>\n                  <sdo:Token>\n                     <sdo:authtoken>\(token)</sdo:authtoken>\n                  </sdo:Token>\n                   </soapenv:Header>\n                   <soapenv:Body>\n                      <sdo:Logout>?</sdo:Logout>\n                   </soapenv:Body>\n            </soapenv:Envelope>"
    }

    public static func userInfo(_ token : String) -> String {
        "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n                <soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n                    <soapenv:Header>\n                        <sdo:Token>\n                            <sdo:authtoken>\(token)</sdo:authtoken>\n                    </sdo:Token>\n                    </soapenv:Header>\n                    <soapenv:Body>\n                        <sdo:UserInfo></sdo:UserInfo>\n                    </soapenv:Body>\n                </soapenv:Envelope>"
    }

    public static func userGroupInfo(_ token : String) -> String {
        "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n   <soapenv:Header>\n      <sdo:Token>\n         <sdo:authtoken>\(token)</sdo:authtoken>\n      </sdo:Token>\n   </soapenv:Header>\n   <soapenv:Body>\n      <sdo:GetCurrentEvent>?</sdo:GetCurrentEvent>\n   </soapenv:Body>\n</soapenv:Envelope>"
    }

    public static func userSchedule(token : String, eventId: String) -> String {
        "<soapenv:Envelope xmlns:soapenv=\"http://schemas.xmlsoap.org/soap/envelope/\" xmlns:sdo=\"http://sdo-test.scicet.local/\">\n   <soapenv:Header>\n      <sdo:Token>\n         <sdo:authtoken>\(token)</sdo:authtoken>\n      </sdo:Token>\n   </soapenv:Header>\n   <soapenv:Body>\n      <sdo:GetEventSchedule>\n         <sdo:event_id>\(eventId)</sdo:event_id>\n      </sdo:GetEventSchedule>\n   </soapenv:Body>\n</soapenv:Envelope>"
    }
}
