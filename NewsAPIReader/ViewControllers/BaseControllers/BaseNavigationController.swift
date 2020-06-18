//
//  BaseNavigationController.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import UIKit

class BaseNavigationController: UINavigationController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationBar.prefersLargeTitles = true
  }
}
