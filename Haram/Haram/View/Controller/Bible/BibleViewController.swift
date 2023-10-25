//
//  BibleViewController.swift
//  Haram
//
//  Created by 이건준 on 2023/08/20.
//

import UIKit

import SnapKit
import Then

enum BibleViewType: CaseIterable {
  case todayBibleWord
  case notice
  case todayPray
  
  var title: String {
    switch self {
    case .todayBibleWord:
      return "오늘의성경말씀"
    case .notice:
      return "공지사항"
    case .todayPray:
      return "오늘의기도"
    }
  }
}

final class BibleViewController: BaseViewController {
  
  private let viewModel: BibleViewModelType
  
  private let revisionOfTranlationModel = CoreDataManager.shared.getRevisionOfTranslation(ascending: true)
  
  private var todayBibleWordModel: [String] = [] {
    didSet {
      bibleCollectionView.reloadSections([0])
    }
  }
  
  private lazy var bibleCollectionView = UICollectionView(
    frame: .zero,
    collectionViewLayout: UICollectionViewCompositionalLayout { [weak self] sec, env -> NSCollectionLayoutSection? in
      guard let self = self else { return nil }
      return type(of: self).createCollectionViewSection(type: BibleViewType.allCases[sec])
    }).then {
      $0.register(TodayPrayCollectionViewCell.self, forCellWithReuseIdentifier: TodayPrayCollectionViewCell.identifier)
      $0.register(TodayBibleWordCollectionViewCell.self, forCellWithReuseIdentifier: TodayBibleWordCollectionViewCell.identifier)
      $0.register(BibleNoticeCollectionViewCell.self, forCellWithReuseIdentifier: BibleNoticeCollectionViewCell.identifier)
      $0.register(BibleCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: BibleCollectionHeaderView.identifier)
      $0.dataSource = self
      $0.delegate = self
      $0.contentInset = UIEdgeInsets(top: 124 - 70.4 - 24.6, left: .zero, bottom: .zero, right: .zero)
    }
  
  private lazy var bibleSearchView = BibleSearchView().then {
    $0.delegate = self
    $0.backgroundColor = .white
    $0.layer.masksToBounds = true
    $0.layer.borderWidth = 1
    $0.layer.borderColor = UIColor.hexD8D8DA.cgColor
    $0.layer.cornerRadius = 20
    $0.layer.maskedCorners = CACornerMask(
      arrayLiteral: .layerMinXMinYCorner, .layerMaxXMinYCorner
    )
  }
  
  init(viewModel: BibleViewModelType = BibleViewModel()) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func bind() {
    super.bind()
    
    viewModel.todayBibleWordList
      .drive(rx.todayBibleWordModel)
      .disposed(by: disposeBag)
  }
  
  override func setupStyles() {
    super.setupStyles()
    title = "성경"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      image: UIImage(named: Constants.backButton),
      style: .plain,
      target: self,
      action: #selector(didTappedBackButton)
    )
  }
  
  override func setupLayouts() {
    super.setupLayouts()
    [bibleCollectionView, bibleSearchView].forEach { view.addSubview($0) }
  }
  
  override func setupConstraints() {
    super.setupConstraints()
    bibleCollectionView.snp.makeConstraints {
      $0.directionalEdges.equalToSuperview()
    }
    
    bibleSearchView.snp.makeConstraints {
      $0.height.equalTo(186 - 30)
      $0.directionalHorizontalEdges.bottom.equalToSuperview()
    }
  }
  
  @objc private func didTappedBackButton() {
    navigationController?.popViewController(animated: true)
  }
  
  static func createCollectionViewSection(type: BibleViewType) -> NSCollectionLayoutSection? {
    switch type {
    case .todayBibleWord:
      let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(22)
      ))
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(22)
        ),
        subitems: [item]
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(24)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: 13, leading: 15, bottom: 28, trailing: 15)
      section.boundarySupplementaryItems = [header]
      return section
    case .notice:
      let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(161 + 6 + 12 + 22)
      ))
      
      let group = NSCollectionLayoutGroup.vertical(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(161 + 6 + 12 + 22)
        ),
        subitems: [item]
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(24)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 15, bottom: 28, trailing: 15)
      section.boundarySupplementaryItems = [header]
      return section
    case .todayPray:
      let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(
        widthDimension: .fractionalWidth(1),
        heightDimension: .estimated(85)
      ))
      
      let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .estimated(85)
        ),
        subitems: [item]
      )
      
      let header = NSCollectionLayoutBoundarySupplementaryItem(
        layoutSize: NSCollectionLayoutSize(
          widthDimension: .fractionalWidth(1),
          heightDimension: .absolute(24)
        ),
        elementKind: UICollectionView.elementKindSectionHeader,
        alignment: .top
      )
      
      let section = NSCollectionLayoutSection(group: group)
      section.boundarySupplementaryItems = [header]
      section.contentInsets = NSDirectionalEdgeInsets(top: 14, leading: 15, bottom: 156 + 15, trailing: 15)
      section.interGroupSpacing = 20
      return section
    }
  }
}

extension BibleViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return BibleViewType.allCases.count
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    if BibleViewType.allCases[section] == .todayPray {
      return 1
    }
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    switch BibleViewType.allCases[indexPath.section] {
    case .todayBibleWord:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayBibleWordCollectionViewCell.identifier, for: indexPath) as? TodayBibleWordCollectionViewCell ?? TodayBibleWordCollectionViewCell()
      cell.configureUI(with: todayBibleWordModel.first ?? "")
      return cell
    case .notice:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BibleNoticeCollectionViewCell.identifier, for: indexPath) as? BibleNoticeCollectionViewCell ?? BibleNoticeCollectionViewCell()
      cell.configureUI(with: "[공지사항] 하람 애플리케이션 서비스 사용안내")
      return cell
    case .todayPray:
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TodayPrayCollectionViewCell.identifier, for: indexPath) as? TodayPrayCollectionViewCell ?? TodayPrayCollectionViewCell()
      cell.configureUI(with: .init(prayTitle: "이건준, 컴소4", prayContent: "성공적으로 하람이 계획한대로 마무리되었으면 좋겠습니다. 하람팀원인 성묵이 상우에게도 좋은 기운이 취업에 있어서 가득하길 기도합니다 "))
      return cell
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: BibleCollectionHeaderView.identifier, for: indexPath) as? BibleCollectionHeaderView ?? BibleCollectionHeaderView()
    header.configureUI(with: BibleViewType.allCases[indexPath.section].title)
//    header.backgroundColor = .red
    return header
  }
}

extension BibleViewController: BibleSearchViewDelgate {
  func didTappedJeolControl() {
    let bottomSheet = BibleBottomSheetViewController(type: .revisionOfTranslation(revisionOfTranlationModel))
    bottomSheet.delegate = self
    present(bottomSheet, animated: true)
  }
  
  func didTappedChapterControl() {
    let selectedRevisionOfTranslation = bibleSearchView.getRevisionOfTranslation()
    let selectedChapter = revisionOfTranlationModel.filter { $0.bibleName == selectedRevisionOfTranslation }.first?.chapter ?? 1
    let bottomSheet = BibleBottomSheetViewController(type: .chapter(Array(1...Int(selectedChapter))))
    bottomSheet.delegate = self
    present(bottomSheet, animated: true)
  }
  
  func didTappedSearchButton(book: String, chapter: Int) {
    let vc = BibleSearchResultViewController(request: .init(
      bibleType: .RT,
      book: book,
      chapter: chapter
    ))
    vc.navigationItem.largeTitleDisplayMode = .never
    navigationController?.pushViewController(vc, animated: true)
  }
}

extension BibleViewController: BibleBottomSheetViewControllerDelegate {
  func didTappedRevisionOfTranslation(bibleName: String) {
    bibleSearchView.updateJeolBibleName(bibleName: bibleName)
    bibleSearchView.updateChapter(chapter: "1")
  }
  
  func didTappedChapter(chapter: String) {
    bibleSearchView.updateChapter(chapter: chapter)
  }
}
