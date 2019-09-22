//
//  ViewController.swift
//  SoapExamples
//
//  Created by Denis Islamov on 21/09/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import UIKit

class ViewController: UIViewController, SoapWebServiceDelegate {
    let login : String  = "vg_02";
    let pass : String   = "vg_02";
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
    }

    func userInfoReceived(value : UserInfo) {
        print(value)
    }

    func errorReceived(value : String) {
        print("error: " + value)
    }
}
