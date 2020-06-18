//
//  FavoritesViewModel.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import RxSwift

class FavoritesViewModel: NSObject {
  let selectedArticle = PublishSubject<Article>()
  var favorites: CoreDataObservable<Article> {
    CoreDataService.shared.favoritesObservable
  }
}
extension FavoritesViewModel: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard indexPath.row < CoreDataService.shared.favorites.count else {
      return UITableView.automaticDimension
    }
    let article = CoreDataService.shared.favorites[indexPath.row]
    
    return NewCell.calcHeight(title: article.title, date: article.publishedAt?.dateString)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.row < CoreDataService.shared.articles.count {
      selectedArticle.onNext(CoreDataService.shared.favorites[indexPath.row])
    }
  }
}
