//
//  AllNewsViewController.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import UIKit
import RxSwift

class AllNewsViewController: BaseTableViewController<AllNewsViewModel> {
  override var isLargeTitleNeeded: Bool { true }
  
  weak var activityIndicatorView: UIActivityIndicatorView!
  
  private let disposeBag = DisposeBag()
  
  let reuseIdentifier = "NewCell"
  lazy var dataSource: UITableViewDiffableDataSource<Section, Article> = {
    let reuseIdentifier = self.reuseIdentifier
    return UITableViewDiffableDataSource<Section, Article>(tableView: self.tableView) {
      (tableView, indexPath, article) -> UITableViewCell? in
      let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier,
                                               for: indexPath) as? NewCell
      cell?.configureCell()
      cell?.setupContent(article)
      return cell
    }
  }()
  
  override func setupSubviews() {
    super.setupSubviews()
    
    tableView.register(NewCell.self, forCellReuseIdentifier: reuseIdentifier)
    createActivityIndicator()
    let searchController = UISearchController(searchResultsController: nil)
    searchController.searchBar.placeholder = "Искать новости"
    searchController.searchBar.delegate = viewModel
    searchController.obscuresBackgroundDuringPresentation = false
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = true
  }

  override func setupStyle() {
    title = "Все новости"
  }
  
  override func setupReactive() {
    tableView.rx
      .setDelegate(viewModel)
      .disposed(by: disposeBag)
    
    viewModel.isLoading.asObservable()
      .map { !$0 }
      .bind(to: activityIndicatorView.rx.isHidden)
      .disposed(by: disposeBag)
    
    viewModel.updateFavorite
      .subscribe(onNext: { [weak self] article in
        self?.tableView.visibleCells
          .compactMap { $0 as? NewCell }
          .filter { $0.titleLabel.text == article.title }
          .forEach { $0.setupContent(article) }
      })
      .disposed(by: disposeBag)
    
    viewModel.scrollToTop
      .subscribe(onNext: { [weak self] in
        self?.tableView.scrollRectToVisible(.zero, animated: true)
      })
      .disposed(by: disposeBag)
    
    viewModel.filteredArticles
      .subscribe(onNext: { [weak self] articles in
        var snapshot = NSDiffableDataSourceSnapshot<Section, Article>()
        snapshot.appendSections([.all])
        snapshot.appendItems(articles)
        self?.dataSource.apply(snapshot)
      })
      .disposed(by: disposeBag)
    
    viewModel.selectedArticle.asObservable()
      .subscribe(onNext: { [weak self] selectedArticle in
        let articleController = ArticleViewController.create(viewModel: ArticleViewModel(article: selectedArticle))
        self?.navigationController?.show(articleController, sender: nil)
      })
      .disposed(by: disposeBag)
    
    viewModel.presentError.asObservable()
      .subscribe(onNext: { [weak self] errorDescription in
        let alert = UIAlertController(title: errorDescription, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self?.present(alert, animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
  }
  
  func createActivityIndicator() {
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
     let barButton = UIBarButtonItem(customView: activityIndicator)
     self.navigationItem.setRightBarButton(barButton, animated: true)
     self.activityIndicatorView = activityIndicator
     activityIndicator.startAnimating()
  }
}
