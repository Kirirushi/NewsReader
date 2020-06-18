//
//  BaseTabBarController.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 16/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import UIKit

class BaseTabBarController: UITabBarController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    selectedIndex = 0
  }
}
extension BaseTabBarController {
  static func createBaseTabBar() -> BaseTabBarController {
    let tabBarController = BaseTabBarController()
    let topHeadings = BaseNavigationController(rootViewController: NewsListViewController.create(viewModel: NewsListViewModel()))
    topHeadings.tabBarItem.image = UIImage(systemName: "flame")
    topHeadings.tabBarItem.title = "Топ-заголовки"
    let everything = BaseNavigationController(rootViewController: AllNewsViewController.create(viewModel: AllNewsViewModel()))
    everything.tabBarItem.image = UIImage(systemName: "magnifyingglass")
    everything.tabBarItem.title = "Все новости"
    let favorites = BaseNavigationController(rootViewController: FavoritesViewController.create(viewModel: FavoritesViewModel()))
    favorites.tabBarItem.image = UIImage(systemName: "star")
    favorites.tabBarItem.title = "Избранное"
    tabBarController.setViewControllers([topHeadings, favorites, everything], animated: false)

    return tabBarController
  }
}
