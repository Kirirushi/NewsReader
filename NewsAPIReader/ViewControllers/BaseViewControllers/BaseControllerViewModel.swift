//
//  BaseControllerViewModel.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import UIKit
import RxSwift

class BaseControllerViewModel {
  var dismissNavigationController = PublishSubject<Void>()
  var dismissViewController = PublishSubject<Void>()
  var popViewController = PublishSubject<Void>()
  let presentViewController = BehaviorSubject<UIViewController?>(value: nil)
  var showViewController = PublishSubject<UIViewController>()
  var popToRootViewController = PublishSubject<Void>()
  
  var navigationBarHeight: CGFloat {
    if (UIScreen.main.bounds.height < 812) {
      return 44.0
    } else {
      return 70.0
    }
  }
  
  init() {
    setupModel()
  }
  
  func setupModel() {
    
  }
  
  func showError(message: String) {
    let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "ОК", style: .default, handler: nil))
    self.presentViewController.onNext(alertController)
  }

  func reloadData() {

  }
}
