//
//  ArticleViewModel.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import RxSwift

class ArticleViewModel {
  let article: Article
  
  init(article: Article) {
    self.article = article
  }
}
