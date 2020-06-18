//
//  BaseViewController.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import RxSwift
class BaseViewController: UIViewController {
  static var name: String {
    return String(describing: self)
  }
  
  private var disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()

  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    view.endEditing(true)
  }
  
  func setupModel(_ model: BaseControllerViewModel) {
    model.dismissViewController.asObserver()
      .subscribe(onNext: { [weak self] () in
        self?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    model.popViewController.asObserver()
      .subscribe(onNext: { [weak self] () in
        self?.navigationController?.popViewController(animated: true)
      })
      .disposed(by: disposeBag)
    
    model.presentViewController.asObserver()
      .subscribe(onNext: { [weak self] (viewController) in
        if let vc = viewController {
          self?.present(vc, animated: true, completion: nil)
        }
      })
      .disposed(by: disposeBag)
    
    model.showViewController.asObserver()
      .subscribe(onNext: { [weak self] (viewController) in
        self?.view.endEditing(true)
        self?.navigationController?.show(viewController, sender: self)
      })
      .disposed(by: disposeBag)
    
    model.dismissNavigationController.asObserver()
      .subscribe(onNext: { [weak self] in
        self?.view.endEditing(true)
        self?.navigationController?.dismiss(animated: true, completion: nil)
      })
      .disposed(by: disposeBag)
    
    model.popToRootViewController.asObserver()
      .subscribe(onNext: { [weak self] in
        self?.view.endEditing(true)
        self?.navigationController?.popToRootViewController(animated: true)
      })
      .disposed(by: disposeBag)
  }
  
//  func shareURL(url: URL?, sourceView: UIView? = nil) {
//    let activityViewController = UIActivityViewController(
//      activityItems: [url], applicationActivities: nil)
//    activityViewController.popoverPresentationController?.sourceView = sourceView
//    activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
//
//    activityViewController.excludedActivityTypes = [
//      .postToWeibo,
//      .print,
//      .assignToContact,
//      .saveToCameraRoll,
//      .addToReadingList,
//      .postToFlickr,
//      .postToVimeo,
//      .postToTencentWeibo,
//      .copyToPasteboard
//    ]
//
//    self.present(activityViewController, animated: true, completion: nil)
//  }
}
