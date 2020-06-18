//
//  BaseViewController.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 17/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import UIKit

class BaseViewController<ViewModelType>: UIViewController {
  var isLargeTitleNeeded: Bool { true }
  
  var viewModel: ViewModelType!
  
  override func loadView() {
    super.loadView()
    
    setupSubviews()
  }
  
  func setupSubviews() {}
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupStyle()
    setupReactive()
  }
  
  func setupStyle() {}
  func setupReactive() {}
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    navigationItem.largeTitleDisplayMode = isLargeTitleNeeded ? .always : .never
  }
  
  static func create(viewModel: ViewModelType) -> Self {
    let viewController = Self()
    viewController.viewModel = viewModel
    return viewController
  }
  
  func share(text: String? = "", url: URL?) {
    if let url = url, let text = text {
      let objectsToShare = [text,url] as [Any]
      let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
      present(activityVC, animated: true, completion: nil)
    }
  }
}
