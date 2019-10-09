//
//  RssNewsManager.swift
//  SoapExamples
//
//  Created by Denis Islamov on 07/10/2019.
//  Copyright © 2019 ___FORMIKALAB___. All rights reserved.
//

import Foundation

protocol RssNewsManagerDelegate : class {
    func rssNewsReceived(value: [RssNewsArticle])
}

class RssNewsManager : NSObject, XMLParserDelegate {
    private var url : String = "https://rosatomtech.ru/category/news/feed/"

    private var parasedData = [[String:String]]()

    private weak var rssNewsManagerDelegate : RssNewsManagerDelegate!

    var rssNewsArticles : [RssNewsArticle] = []
    var newRssNewsArticle : RssNewsArticle? = nil

    enum StateRssNewsArticle { case none, item, title, link, pubDate, description }
    var stateRssNewsArticle : StateRssNewsArticle = .none

    public init(rssNewsManagerDelegateRef : RssNewsManagerDelegate) {
        rssNewsManagerDelegate = rssNewsManagerDelegateRef
    }

    public func startParsingWithContentsOfURL() {
        let xmlParser = XMLParser(contentsOf: URL(string: url)!)
        xmlParser?.delegate = self
        if xmlParser!.parse() {
            rssNewsManagerDelegate.rssNewsReceived(value: self.rssNewsArticles)
        }
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        switch elementName {
            case "item":
                stateRssNewsArticle = .item
                self.newRssNewsArticle = RssNewsArticle()
            case "title":
                if stateRssNewsArticle == .item {
                    stateRssNewsArticle = .title
                }
            case "link":
                stateRssNewsArticle = .link
            case "pubDate":
                stateRssNewsArticle = .pubDate
            case "description":
                stateRssNewsArticle = .description
            default:
                stateRssNewsArticle = .none
        }
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if let rssNewsArticle = self.newRssNewsArticle, elementName == "item" {
            self.rssNewsArticles.append(rssNewsArticle)
            self.newRssNewsArticle = nil
        }
        self.stateRssNewsArticle = .none
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let _ = self.newRssNewsArticle else { return }

        switch self.stateRssNewsArticle {
            case .title:
                self.newRssNewsArticle?.title = string
            case .link:
                self.newRssNewsArticle?.link = string
            case .pubDate:
                self.newRssNewsArticle?.pubDate = string
            case .description:
                if string.contains("src=\"") && string.contains("\" class=") {
                    self.newRssNewsArticle?.imageUrl = string.slice(from: "src=\"", to: "\" class=")!
                }
            default:
              break
        }
    }
}
