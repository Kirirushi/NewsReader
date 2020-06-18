//
//  BaseTableViewCell.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import UIKit
import RxSwift

class BaseTableViewCell: UITableViewCell {
  var disposeBag = DisposeBag()
  var cellHeight: Int?
  
  override func prepareForReuse() {
    super.prepareForReuse()
    disposeBag = DisposeBag()
  }
   
  static func cellIdentifier() -> String {
    return String(describing: self)
  }

  func configureCell(_ cellModel: BaseCellViewModel) {
    cellModel.tableViewCell = self
  }

  func setSelectedCell() {

  }
   
  func deselectCell() {

  }
   
  let animationRatio: CGFloat = 0.9
  var reverseAnimationRatio: CGFloat {
    1 / animationRatio
  }
  
  func animateOnSelect() {
    let originalTransform = self.transform
    let scaledTransform = originalTransform.scaledBy(x: animationRatio, y: animationRatio)
    UIView.animate(withDuration: 0.2, animations: {
      self.transform = scaledTransform
    })
  }
   
  func animateOnDeselect() {
    let originalTransform = self.transform
    let scaledTransform = originalTransform.scaledBy(x: reverseAnimationRatio, y: reverseAnimationRatio)
    UIView.animate(withDuration: 0.2, animations: {
      self.transform = scaledTransform
    })
  }
}
