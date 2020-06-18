//
//  NewsListViewModel.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 16/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import RxSwift
import CoreData

class NewsListViewModel: NSObject {
  let presentError = PublishSubject<String>()
  
  let loadPage = PublishSubject<Int>()
  var currentPage = 0
  var articlesCount = 1
  
  let isLoading = BehaviorSubject<Bool>(value: false)
  var loading = false
  
  let updateFavorite = PublishSubject<Article>()
  
  let selectedArticle = PublishSubject<Article>()
  
  private let disposeBag = DisposeBag()
  
  override init() {
    super.init()
    setupModel()
  }
  
  var topRecent: CoreDataObservable<Article> {
    CoreDataService.shared.topRecentObservable
  }
  
  private func setupModel() {
    isLoading
      .subscribe(onNext: { [weak self] isLoading in
        self?.loading = isLoading
      })
      .disposed(by: disposeBag)
    
    CoreDataService.shared.favoriteChanged
      .filter({ (_, isFavorite) -> Bool in
        return !isFavorite
      })
      .map({ (article, _) -> Article in
        return article
      })
      .bind(to: updateFavorite)
      .disposed(by: disposeBag)
    
    loadPage
      .flatMapLatest { [weak self] page -> Observable<Result<EverythingModel, APIError>> in
        self?.isLoading.onNext(true)
        return APIService.shared.loadTopHeadlines(page: page)
      }
      .map({ [weak self] result -> [NewsModel]? in
        if case let .success(success) = result {
          self?.articlesCount = success.totalResults ?? 0
          return success.articles
        } else if case let .failure(error) = result,
          case let .serverError(description) = error {
          self?.presentError.onNext(description)
        }
        self?.isLoading.onNext(false)
        return nil
      })
      .compactMap { $0 }
      .subscribe(onNext: { [weak self] models in
        CoreDataService.shared.saveTopRecent(with: models)
        self?.isLoading.onNext(false)
      })
      .disposed(by: disposeBag)
  }
}

extension NewsListViewModel: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard indexPath.row < CoreDataService.shared.articles.count else {
      return UITableView.automaticDimension
    }
    let article = CoreDataService.shared.articles[indexPath.row]
    
    return NewCell.calcHeight(title: article.title, date: article.publishedAt?.dateString)
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.row < CoreDataService.shared.articles.count {
      selectedArticle.onNext(CoreDataService.shared.articles[indexPath.row])
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    let contentHeight = scrollView.contentSize.height
    let height = scrollView.frame.size.height
    if offsetY > contentHeight - height {
      if !loading, CoreDataService.shared.articles.count < self.articlesCount {
        currentPage += 1
        loadPage.onNext(currentPage)
      }
    }
  }
}
