//
//  RssNewsManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 07/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

class RssNewsManager : NSObject, XMLParserDelegate {
    private var url : String = "https://rosatomtech.ru/category/news/feed/"

    private var xmlParser : XMLParser!
    private var parasedData = [[String:String]]()

    func startParsingWithContentsOfURL(rssURL : URL, with completion: (Bool)->()) {
        let parser = XMLParser(contentsOf: rssURL)
        parser?.delegate = self

        xmlParser.parse()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
    }
}
