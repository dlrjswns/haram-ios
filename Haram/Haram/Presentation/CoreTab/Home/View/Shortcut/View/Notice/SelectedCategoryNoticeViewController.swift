//
//  SelectedCategoryNoticeViewController.swift
//  Haram
//
//  Created by 이건준 on 1/17/24.
//

import UIKit

import SnapKit
import SkeletonView
import Then

final class SelectedCategoryNoticeViewController: BaseViewController {
  
  private let viewModel: SelectedCategoryNoticeViewModelType
  private let noticeType: NoticeType
  
  private var noticeModel: [NoticeCollectionViewCellModel] = [] {
    didSet {
      noticeCollectionView.reloadData()
    }
  }
  
  private lazy var noticeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout()
  ).then {
    $0.backgroundColor = .white
    $0.register(NoticeCollectionViewCell.self, forCellWithReuseIdentifier: NoticeCollectionViewCell.identifier)
    $0.delegate = self
    $0.dataSource = self
    $0.showsVerticalScrollIndicator = false
    $0.contentInsetAdjustmentBehavior = .always
    $0.isSkeletonable = true
  }
  
  init(noticeType: NoticeType, viewModel: SelectedCategoryNoticeViewModelType = SelectedCategoryNoticeViewModel()) {
    self.viewModel = viewModel
    self.noticeType = noticeType
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    
    viewModel.inquireNoticeList(type: noticeType)
    
    viewModel.noticeCollectionViewCellModel
      .drive(rx.noticeModel)
      .disposed(by: disposeBag)
    
    viewModel.isLoading
      .filter { !$0 }
      .drive(with: self) { owner, _ in
        owner.view.hideSkeleton()
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "공지사항"
    setupBackButton()
    setupSkeletonView()
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    view.addSubview(noticeCollectionView)
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    noticeCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
  }
}

extension SelectedCategoryNoticeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let vc = NoticeDetailViewController(path: noticeModel[indexPath.row].path)
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension SelectedCategoryNoticeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return noticeModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeCollectionViewCell.identifier, for: indexPath) as? NoticeCollectionViewCell ?? NoticeCollectionViewCell()
    cell.configureUI(with: noticeModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: collectionView.frame.width - 30, height: 92)
  }
  
  
}

extension SelectedCategoryNoticeViewController: BackButtonHandler {
  func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
}

extension SelectedCategoryNoticeViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    NoticeCollectionViewCell.identifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, skeletonCellForItemAt indexPath: IndexPath) -> UICollectionViewCell? {
    skeletonView.dequeueReusableCell(withReuseIdentifier: NoticeCollectionViewCell.identifier, for: indexPath) as? NoticeCollectionViewCell
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
  
  
}
