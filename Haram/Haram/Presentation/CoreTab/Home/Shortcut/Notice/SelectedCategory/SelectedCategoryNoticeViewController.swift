//
//  SelectedCategoryNoticeViewController.swift
//  Haram
//
//  Created by 이건준 on 1/17/24.
//

import UIKit

import RxSwift
import SnapKit
import SkeletonView
import Then

final class SelectedCategoryNoticeViewController: BaseViewController {
  
  private let viewModel: SelectedCategoryNoticeViewModel
  
  private lazy var noticeCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewFlowLayout().then {
      $0.scrollDirection = .vertical
      $0.minimumLineSpacing = 20
    }
  ).then {
    $0.backgroundColor = .white
    $0.register(NoticeCollectionViewCell.self)
    $0.delegate = self
    $0.dataSource = self
    $0.showsVerticalScrollIndicator = true
    $0.contentInsetAdjustmentBehavior = .always
    $0.isSkeletonable = true
    $0.contentInset = .init(top: 20, left: .zero, bottom: 15, right: .zero)
    $0.alwaysBounceVertical = true
  }
  
  init(viewModel: SelectedCategoryNoticeViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    let input = SelectedCategoryNoticeViewModel.Input(
      viewDidLoad: .just(()),
      didTapBackButton: navigationItem.leftBarButtonItem!.rx.tap.asObservable(), 
      didTapNoticeCell: noticeCollectionView.rx.itemSelected.asObservable()
    )
    bindNotificationCenter(input: input)
    
    let output = viewModel.transform(input: input)
    
    output.noticeCollectionViewCellModel
      .asDriver()
      .filter { !$0.isEmpty }
      .drive(with: self) { owner, noticeModel in
        owner.view.hideSkeleton()
        owner.noticeCollectionView.reloadData()
      }
      .disposed(by: disposeBag)
    
    noticeCollectionView.rx.didScroll
      .subscribe(with: self) { owner, _ in
        let offSetY = owner.noticeCollectionView.contentOffset.y
        let contentHeight = owner.noticeCollectionView.contentSize.height
        
        if offSetY > (contentHeight - owner.noticeCollectionView.frame.size.height - 92 * 3) {
          input.fetchMoreDatas.onNext(())
        }
      }
      .disposed(by: disposeBag)
    
    output.errorMessage
      .asSignal()
      .emit(with: self) { owner, error in
        if error == .networkError {
          AlertManager.showAlert(message: .networkUnavailable, actions: [
            DefaultAlertButton {
              guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
              if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
              }
            }
          ])
        }
      }
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
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

extension SelectedCategoryNoticeViewController {
  private func bindNotificationCenter(input: SelectedCategoryNoticeViewModel.Input) {
    NotificationCenter.default.rx.notification(.refreshWhenNetworkConnected)
      .map { _ in Void() }
      .bind(to: input.didConnectNetwork)
      .disposed(by: disposeBag)
  }
}

extension SelectedCategoryNoticeViewController: UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
    
    if collectionView == noticeCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? NoticeCollectionViewCell ?? NoticeCollectionViewCell()
      cell.setHighlighted(isHighlighted: true)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
    
    if collectionView == noticeCollectionView {
      let cell = collectionView.cellForItem(at: indexPath) as? NoticeCollectionViewCell ?? NoticeCollectionViewCell()
      cell.setHighlighted(isHighlighted: false)
      
    }
  }
}

extension SelectedCategoryNoticeViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return viewModel.noticeModel.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(NoticeCollectionViewCell.self, for: indexPath) ?? NoticeCollectionViewCell()
    cell.configureUI(with: viewModel.noticeModel[indexPath.row])
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: collectionView.frame.width - 30, height: 92)
  }
  
  
}

extension SelectedCategoryNoticeViewController: SkeletonCollectionViewDataSource {
  func collectionSkeletonView(_ skeletonView: UICollectionView, cellIdentifierForItemAt indexPath: IndexPath) -> SkeletonView.ReusableCellIdentifier {
    NoticeCollectionViewCell.reuseIdentifier
  }
  
  func collectionSkeletonView(_ skeletonView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    10
  }
}
