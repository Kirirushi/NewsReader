//
//  BaseTableViewController.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//
import RxSwift
import UIKit

class BaseTableViewController: BaseViewController {
  weak var tableView: UITableView!
  
  var estimatedRowHeight: CGFloat = 500

  var structureViewModel: BaseTableViewModel!
  private let disposeBag = DisposeBag()
  
  override func loadView() {
    super.loadView()
    createTableView()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.dataSource = nil
    tableView.delegate = nil
    tableView.estimatedRowHeight = estimatedRowHeight
    
    tableView.rx
      .setDelegate(self)
      .disposed(by: disposeBag)
    
    structureViewModel.tableViewOutput.cellModels.asObservable()
      .bind(to: tableView.rx.items) { tableView, _, model in
        tableView.register(model.tableViewCell?.classForCoder, forCellReuseIdentifier: model.cellIdentifier)
        if let cell = tableView.dequeueReusableCell(withIdentifier: model.cellIdentifier) as? BaseTableViewCell {
          cell.configureCell(model)
          return cell
        } else {
          fatalError()
        }
      }
      .disposed(by: disposeBag)
    
    tableView.rx.modelSelected(BaseCellViewModel.self).subscribe(onNext: { (cellModel) in
      if let closure = cellModel.onClickCellBlock {
        closure(cellModel)
      }
    }).disposed(by: disposeBag)

    structureViewModel.tableViewOutput.reloadCell.asObservable()
      .subscribe(onNext: { [weak self] cell in
        guard let cell = cell, let indexPath = self?.tableView.indexPath(for: cell) else { return }
        self?.tableView.reloadRows(at: [indexPath], with: .none)
      })
      .disposed(by: disposeBag)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    structureViewModel.createCellModels()
  }
  
  func scrollToTop() {
    if tableView == nil { return }
    if tableView.numberOfRows(inSection: 0) > 0 {
      tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
  }
  
  func createTableView() {
    let tableView = UITableView(frame: view.bounds, style: .plain)
    
    view.addSubview(tableView)
    tableView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
    }
    self.tableView = tableView
  }
}

extension BaseTableViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if let height = structureViewModel.tableViewOutput.models[indexPath.row].cellHeight {
      return height
    }
    return UITableView.automaticDimension
  }
  
  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    if let height = structureViewModel.tableViewOutput.models[indexPath.row].cellHeight {
      return height
    }
    if #available(iOS 13.0, *) {
      return estimatedRowHeight
    } else {
      return UITableView.automaticDimension
    }
  }
  
  func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    let cellModel = structureViewModel.tableViewOutput.models[indexPath.row]
    if cellModel.animationOnTap == false { return }
    guard let cell = cellModel.tableViewCell else { return }
    cell.animateOnSelect()
  }
  
  func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
    let cellModel = structureViewModel.tableViewOutput.models[indexPath.row]
    if cellModel.animationOnTap == false { return }
    guard let cell = cellModel.tableViewCell else { return }
    cell.animateOnDeselect()
  }
  
}

