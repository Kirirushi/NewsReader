//
//  ArticleViewController.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import SnapKit
import UIKit
import RxSwift
import WebKit

class ArticleViewController: BaseViewController<ArticleViewModel> {
  override var isLargeTitleNeeded: Bool { false }
  
  weak var webView: WKWebView!
  weak var activityIndicatorView: UIActivityIndicatorView!
  weak var shareButton: UIBarButtonItem!
  weak var favoriteButton: UIButton!
  
  private let disposeBag = DisposeBag()
  
  override func setupSubviews() {
    createWebView()
    setupNavigationBarItems()
  }
  
  func setupNavigationBarItems() {
    let share = createShareButton()
    let activity = createActivityIndicator()
    let favorite = createFavoriteButton()
    navigationItem.setRightBarButtonItems([favorite.0,
                                           share,
                                           activity.0], animated: true)
    shareButton = share
    favoriteButton = favorite.1
    activityIndicatorView = activity.1
  }
  
  let favoriteImage = UIImage(systemName: "star.fill")
  let notFavoriteImage = UIImage(systemName: "star")
  
  func createFavoriteButton() -> (UIBarButtonItem, UIButton) {
    let button = UIButton()
    button.setImage(notFavoriteImage, for: .normal)
    button.setImage(favoriteImage, for: .selected)
    return (UIBarButtonItem(customView: button), button)
  }
  
  func createShareButton() -> UIBarButtonItem {
    return UIBarButtonItem(barButtonSystemItem: .action, target: nil, action: nil)
  }
  
  func createActivityIndicator() -> (UIBarButtonItem, UIActivityIndicatorView) {
    let activityIndicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
     let barButton = UIBarButtonItem(customView: activityIndicator)
     activityIndicator.startAnimating()
    return (barButton, activityIndicator)
  }
  
  func createWebView() {
    let wV = WKWebView()
    view.addSubview(wV)
    webView = wV
    
    webView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    if let url = viewModel.article.url {
      let urlRequest = URLRequest(url: url)
      webView.load(urlRequest)
    } else {
      self.navigationController?.popViewController(animated: true)
    }
  }
  
  override func setupReactive() {
    webView.rx.didStartLoad
      .subscribe(onNext: { [weak self] _ in
        self?.activityIndicatorView.isHidden = false
      })
      .disposed(by: disposeBag)
    
    webView.rx.didFinishLoad
      .subscribe(onNext: { [weak self] _ in
        self?.activityIndicatorView.isHidden = true
      })
      .disposed(by: disposeBag)
    
    favoriteButton.rx.tap
    .debug()
      .subscribe(onNext: { [weak self] () in
        guard let self = self else { return }
        let isFavorite = !self.viewModel.article.favorite
        self.favoriteButton.isSelected = isFavorite
        CoreDataService.shared.updateFavorite(title: self.viewModel.article.title ?? "", favorite: isFavorite)
      })
      .disposed(by: disposeBag)
    
    shareButton.rx.tap
      .subscribe(onNext: { [weak self] () in
        self?.share(text: self?.viewModel.article.title, url: self?.viewModel.article.url)
      })
      .disposed(by: disposeBag)
    
    CoreDataService.shared.favoriteChanged
      .compactMap({ [weak self] (article, isFavorite) -> Bool? in
        return article == self?.viewModel.article ? isFavorite : nil
      })
      .bind(to: favoriteButton.rx.isSelected)
      .disposed(by: disposeBag)
  }
}
