//
//  NewsModel.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import ObjectMapper

enum ArticleType: NSDecimalNumber {
  case topRecent = 1
  case all = 2
}

struct NewsModel: Mappable {
  var author: String?
  var title: String?
  var description: String?
  var url: String?
  var urlToImage: String?
  var publishedAt: String?
  var content: String?
  
  init?(map: Map) {}
  
  mutating func mapping(map: Map) {
    author      <- map["author"]
    content     <- map["content"]
    description <- map["description"]
    publishedAt <- map["publishedAt"]
    title       <- map["title"]
    url         <- map["url"]
    urlToImage  <- map["urlToImage"]
  }
}


