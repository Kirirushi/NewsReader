//
//  DateExtension.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import Foundation

extension Date {
  var currentDateString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return dateFormatter.string(from: self)
  }
  var dateString: String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd MMMM yyyy 'в' HH:mm"
    dateFormatter.locale = Locale(identifier: "ru_RU")
    return dateFormatter.string(from: self)
  }
}
