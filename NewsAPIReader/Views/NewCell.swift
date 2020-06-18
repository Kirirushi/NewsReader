//
//  NewCell.swift
//  NewsAPIReader
//
//  Created by Игровой Kirirushi on 15/06/2020.
//  Copyright © 2020 Kirirushi. All rights reserved.
//

import Kingfisher
import UIKit
import RxSwift

class NewCell: UITableViewCell {
  weak var containerView: UIView!
  weak var titleImageView: UIImageView!
  weak var titleLabel: UILabel!
  weak var dateLabel: UILabel!
  weak var favoriteButton: UIButton!
  
  private let disposeBag = DisposeBag()
  
  func setupContent(_ model: Article) {
    if let imageUrl = model.urlToImage {
      titleImageView.kf.setImage(with: imageUrl)
    } else {
      titleImageView.image = UIImage(named: "NoImage")
    }
    titleLabel.text = model.title
    dateLabel.text = model.publishedAt?.dateString
    favoriteButton.isSelected = model.favorite
  }
  
  func configureCell() {
    backgroundColor = .clear
    createContainerView()
    createImage()
    createTitleLabel()
    createDateLabel()
    createFavoriteButton()
  }
  
  func createContainerView() {
    guard containerView == nil else { return }
    let view = UIView()
    addSubview(view)
    containerView = view
    containerView.snp.makeConstraints { make in
      make.center.equalToSuperview()
      make.width.equalToSuperview().offset(-16)
      make.height.equalToSuperview().offset(-16)
    }
    
    containerView.layer.cornerRadius = 8
    containerView.layer.masksToBounds = true
    containerView.layer.shadowColor = UIColor.black.cgColor
    containerView.layer.shadowOffset = CGSize(width: 0, height: 4)
    containerView.layer.shadowRadius = 5
    containerView.layer.shadowOpacity = 0.05
    containerView.backgroundColor = .systemBackground
  }
  
  func createTitleLabel() {
    guard titleLabel == nil else { return }
    let label = UILabel()
    containerView.addSubview(label)
    titleLabel = label
    titleLabel.numberOfLines = 0
    titleLabel.snp.makeConstraints { make in
      make.top.equalTo(titleImageView.snp.bottom).offset(8)
      make.leading.equalTo(8)
      make.trailing.equalTo(-8)
    }
  }
  
  func createDateLabel() {
    guard dateLabel == nil else { return }
    let label = UILabel()
    containerView.addSubview(label)
    dateLabel = label
    dateLabel.numberOfLines = 1
    dateLabel.font = UIFont.systemFont(ofSize: 10)
    dateLabel.textColor = UIColor.systemGray2
    dateLabel.snp.makeConstraints { make in
      make.leading.equalToSuperview().offset(8)
      make.top.equalTo(titleLabel.snp.bottom).offset(4)
    }
  }
  
  func createImage() {
    guard titleImageView == nil else { return }
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    containerView.addSubview(imageView)
    titleImageView = imageView
    titleImageView.kf.indicatorType = .activity
    titleImageView.snp.makeConstraints { make in
      make.top.equalToSuperview()
      make.leading.equalToSuperview()
      make.trailing.equalToSuperview()
      make.width.equalTo(titleImageView.snp.height).multipliedBy(3.0 / 1.75)
    }
    titleImageView.clipsToBounds = true
  }
  
  func createFavoriteButton() {
    guard favoriteButton == nil else { return }
    let button = UIButton()
    containerView.addSubview(button)
    favoriteButton = button
    
    favoriteButton.snp.makeConstraints { make in
      make.width.equalTo(44)
      make.height.equalTo(44)
      make.top.equalToSuperview().offset(8)
      make.trailing.equalToSuperview().offset(-8)
    }
    favoriteButton.setImage(UIImage(systemName: "star"), for: .normal)
    favoriteButton.setImage(UIImage(systemName: "star.fill"), for: .selected)
    favoriteButton.contentMode = .scaleAspectFill
    favoriteButton.tintColor = .systemYellow
    
    favoriteButton.rx.tap
      .subscribe(onNext: { [weak self] () in
        let isFavorite = self?.favoriteButton.isSelected ?? false
        self?.favoriteButton.isSelected = !isFavorite
        CoreDataService.shared.updateFavorite(title: self?.titleLabel.text ?? "", favorite: !isFavorite)
      })
    .disposed(by: disposeBag)
  }
}
extension NewCell {
  static func calcHeight(title: String?, date: String?) -> CGFloat {
    let cardWidth = UIScreen.main.bounds.width - 16
    let imageHeight = cardWidth / 3 * 1.75
    var labelHeights: CGFloat = 16 + 8
    labelHeights += UILabel.calcHeight(with: title,
                                         width: cardWidth - 16)
    labelHeights += UILabel.calcHeight(with: date,
                                         font: UIFont.systemFont(ofSize: 10),
                                         width: cardWidth - 16)
    return imageHeight + 16 + labelHeights
  }
}
