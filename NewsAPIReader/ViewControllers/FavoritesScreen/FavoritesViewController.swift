//
//  FavoritesViewController.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import RxSwift
import UIKit

class FavoritesViewController: BaseTableViewController<FavoritesViewModel> {
  override var isLargeTitleNeeded: Bool { true }
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
  }
  
  override func setupStyle() {
    title = "Избранное"
  }
  
  override func setupReactive() {
    tableView.rx
      .setDelegate(viewModel)
      .disposed(by: disposeBag)
    
    viewModel.favorites
      .subscribe(onNext: { [weak self] articles in
        var snapshot = NSDiffableDataSourceSnapshot<Section, Article>()
        snapshot.appendSections([.favorites])
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
  }
  
}
