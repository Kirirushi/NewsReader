//
//  BaseTableViewController.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import RxSwift
import UIKit

class BaseTableViewController<ViewModelType>: BaseViewController<ViewModelType> {
  weak var tableView: UITableView!
  
  override func setupSubviews() {
    super.setupSubviews()
    createTableView()
  }
  
  func createTableView() {
    let tempTableView = UITableView(frame: .zero)
    view.addSubview(tempTableView)
    tableView = tempTableView
    tableView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    
    tableView.separatorStyle = .none
    tableView.backgroundColor = .secondarySystemBackground
  }
  
  enum Section: CaseIterable {
    case all
    case topRecent
    case favorites
  }
}
