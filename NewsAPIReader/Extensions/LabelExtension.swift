//
//  LabelExtension.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import UIKit

extension UILabel {
  static func calcHeight(with text: String?,
                  font: UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize),
                  width: CGFloat) -> CGFloat {
    let label = UILabel()
    label.numberOfLines = 0
    label.text = text
    label.font = font
    return label.sizeThatFits(CGSize(width: width, height: .infinity)).height
  }
}

