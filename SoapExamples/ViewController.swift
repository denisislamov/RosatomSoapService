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

    override func viewDidLoad() {
        super.viewDidLoad()

        soapWebServiceManager = SoapWebServiceManager(soapWebServiceDelegateRef: self);
    }

    @IBAction func btnClicked(sender: AnyObject) {
        soapWebServiceManager.getToken(login: login, pass: pass, secret: secret)
    }

    func tokenReceived(value : String) {
        print("token: " + value)
        soapWebServiceManager.getUserInfo(token: value)
        soapWebServiceManager.getUserGroup(token: "eyJ0b2tlbl9pZCI6IjY3NDA2NTIxMTczODI5MzMzMzMiLCJwZXJzb25faWQiOiI2NjM2OTg0NjU5ODMzNzQxNzg0IiwiZXhwaXJlZF9kYXRlIjoiMjUuMDkuMjAxOSAyMDo1Mjo1MSIsInJvbGVzIjpbInVzZXIiXX12")
    }

    func userInfoReceived(value : UserInfo) {
        print(value)
    }

    func userGroupReceived(value: UserGroup) {
        print(value)
    }

    func errorReceived(value : String) {
        print("error: " + value)
    }
}
