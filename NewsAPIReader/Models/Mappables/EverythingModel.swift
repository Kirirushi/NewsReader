//
//  EverythingModel.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import ObjectMapper

struct EverythingModel: Mappable {
  var articles: [NewsModel] = []
  var totalResults: Int?
  var status: String?
  var message: String?
  var code: String?
  
  init?(map: Map) {}
  
  mutating func mapping(map: Map) {
    articles      <- map["articles"]
    totalResults  <- map["totalResults"]
    status        <- map["status"]
    message       <- map["message"]
    code          <- map["code"]
  }
}
