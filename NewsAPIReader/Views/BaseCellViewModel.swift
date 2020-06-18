//
//  BaseCellViewModel.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import UIKit
import RxSwift

class BaseCellViewModel {
  typealias ClickCellBlock = (_ cellModel: BaseCellViewModel) -> Void
  typealias ClickCellButton = () -> Void
  
  var cellHeight: CGFloat?
  var tableViewCell: BaseTableViewCell?
  
  var onClickCellBlock: ClickCellBlock?
  var cellIdentifier = ""
  var animationOnTap: Bool { return false }

  init(cellIdentifier: String? = nil) {
    self.cellIdentifier = cellIdentifier ?? BaseTableViewCell.cellIdentifier()
  }
}

