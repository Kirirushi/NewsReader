//
//  BaseTableViewModel.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import RxSwift

class BaseTableViewModel: BaseControllerViewModel {
  struct TableViewOutput {
    let cellModels = BehaviorSubject<[BaseCellViewModel]>(value: [])
    var lastContentOffset: CGPoint = CGPoint(x: 0, y: 0)
    var models = [BaseCellViewModel]()
    let reloadCell = BehaviorSubject<BaseTableViewCell?>(value: nil)
  }
  
  var tableViewOutput = TableViewOutput()
  private let disposeBag = DisposeBag()
  
  override func setupModel() {
    super.setupModel()
    tableViewOutput.cellModels
      .subscribe(onNext: { [weak self] (cellModels) in
        self?.tableViewOutput.models = cellModels
      })
      .disposed(by: disposeBag)
  }
  
  func createCellModels() {
    
  }

}
