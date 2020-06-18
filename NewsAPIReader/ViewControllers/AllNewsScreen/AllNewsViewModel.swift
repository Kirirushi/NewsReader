//
//  AllNewsViewModel.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import RxSwift

class AllNewsViewModel: NSObject {
  let presentError = PublishSubject<String>()
  let scrollToTop = PublishSubject<Void>()
  
  let loadPage = PublishSubject<Int>()
  let searchText = BehaviorSubject<String>(value: "")
  var searchString = ""
  var currentPage = 0
  var articlesCount = 1
  
  let isLoading = BehaviorSubject<Bool>(value: false)
  var loading = false
  
  let updateFavorite = PublishSubject<Article>()
  
  let selectedArticle = PublishSubject<Article>()
  
  var allObservable: CoreDataObservable<Article> {
    CoreDataService.shared.allObservable
  }
  var filteredArticles = BehaviorSubject<[Article]>(value: [])
  
  private let disposeBag = DisposeBag()
  
  override init() {
    super.init()
    setupModel()
  }
  
  private func setupModel() {
    isLoading
      .subscribe(onNext: { [weak self] isLoading in
        self?.loading = isLoading
      })
      .disposed(by: disposeBag)
    
    searchText
      .subscribe(onNext: { [weak self] string in
        self?.searchString = string
      })
      .disposed(by: disposeBag)
    
    CoreDataService.shared.allObservable
      .subscribe(onNext: { [weak self] articles in
        guard let self = self else { return }
        self.filteredArticles.onNext(articles.filter { ($0.title ?? "").contains(self.searchString) })
      })
      .disposed(by: disposeBag)
    
    CoreDataService.shared.favoriteChanged
      .filter { !$1 }
      .map { $0.0 }
      .bind(to: updateFavorite)
      .disposed(by: disposeBag)
    
    searchText.asObservable()
      .subscribe(onNext: { [weak self] searchString in
        self?.scrollToTop.onNext(())
        self?.loadPage.onNext(1)
      })
      .disposed(by: disposeBag)
    
    Observable.combineLatest(loadPage,
                             searchText.debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance))
      .filter { !$1.isEmpty }
      .flatMapLatest { [weak self] page, searchText -> Observable<Result<EverythingModel, APIError>> in
        self?.isLoading.onNext(true)
        return APIService.shared.loadNews(q: searchText, page: page)
      }
    .map { [weak self] result -> [NewsModel]? in
      if case let .success(success) = result {
        self?.articlesCount = success.totalResults ?? 0
        self?.currentPage += 1
        return success.articles
      } else if case let .failure(error) = result,
        case let .serverError(description) = error {
        self?.presentError.onNext(description)
      }
      self?.isLoading.onNext(false)
      return nil
    }
    .compactMap { $0 }
    .subscribe(onNext: { [weak self] models in
      CoreDataService.shared.saveAll(with: models)
      self?.isLoading.onNext(false)
    })
    .disposed(by: disposeBag)
  }
}
extension AllNewsViewModel: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    self.searchText.onNext(searchText)
  }
}
extension AllNewsViewModel: UITableViewDelegate {
  private var filtredArticlesArray: [Article] {
    (try? filteredArticles.value()) ?? []
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    guard indexPath.row < filtredArticlesArray.count else {
      return UITableView.automaticDimension
    }
    let article = filtredArticlesArray[indexPath.row]
    
    return NewCell.calcHeight(title: article.title, date: article.publishedAt?.dateString)
  }
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    if indexPath.row < filtredArticlesArray.count {
      selectedArticle.onNext(filtredArticlesArray[indexPath.row])
    }
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    let offsetY = scrollView.contentOffset.y
    let contentHeight = scrollView.contentSize.height
    let height = scrollView.frame.size.height
    if offsetY > contentHeight - height {
      if !loading, filtredArticlesArray.count < self.articlesCount {
        loadPage.onNext(currentPage + 1)
      }
    }
  }
}
