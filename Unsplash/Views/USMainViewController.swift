//
//  USMainViewController.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import UIKit
import RxSwift
import SnapKit

class USMainViewController: UIViewController {
    typealias CollectionViewCell = USMainCollectionViewCell
    typealias CollectionViewHeader = UICollectionReusableView

    private var viewModel: USMainViewModel!
    private let disposeBag = DisposeBag()
    private var searchResultData: USResponse? {
        didSet {
            self.collectionView.reloadData()
        }
    }

    private var collectionView: UICollectionView!
    private var searchBar: UISearchBar!

    private let cellID = String(describing: CollectionViewCell.self)
    private let headerID = String(describing: CollectionViewHeader.self)

    // MARK: - Initialization
    convenience init() {
        self.init(viewModel: nil)
    }

    init(viewModel: USMainViewModel?) {
        super.init(nibName: nil, bundle: nil)

        self.viewModel = viewModel
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
    }
}

// MARK: - Private Methods
extension USMainViewController {
    private func setupViews() {
        setupSerachBar()
        setupCollectionView()
    }

    private func setupEvents() {
        viewModel.uiEvents.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .requestDataSuccess(let response):
                self.searchResultData = response
            case .requestDataFailure(let error): break
            default: break
            }
        }).disposed(by: disposeBag)
    }

    private func setupSerachBar() {
        if searchBar == nil {
            searchBar = UISearchBar(frame: .zero)
            searchBar.placeholder = "Type here..."
            searchBar.tintColor = .gray
            searchBar.barTintColor = .white
            searchBar.barStyle = .default
            searchBar.isUserInteractionEnabled = true
            searchBar.sizeToFit()
            searchBar.delegate = self
        }
    }

    private func setupCollectionView() {
        if collectionView == nil {
            let collectionViewLayout = UICollectionViewFlowLayout()
            collectionViewLayout.minimumLineSpacing = 10
            collectionViewLayout.minimumInteritemSpacing = 10
            collectionViewLayout.itemSize = CGSize(width: 150, height: 150)
            collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: collectionViewLayout)
            collectionView.register(CollectionViewCell.self,
                                    forCellWithReuseIdentifier: cellID)
            collectionView.register(CollectionViewHeader.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: headerID)
            collectionView.allowsSelection = false
            collectionView.allowsMultipleSelection = false
            collectionView.backgroundColor = .white
            collectionView.delegate = self
            collectionView.dataSource = self

            if !view.subviews.contains(collectionView) {
                view.addSubview(collectionView)
            }

            collectionView.snp.makeConstraints({ make in
                make.top.leading.trailing.bottom.equalToSuperview()
            })
        }
    }
}

// MARK: - UISearchBarDelegate
extension USMainViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        viewModel.viewModelEvents.onNext(.getPhotoData(searchBar.text))
    }
}

// MARK: - UICollectionViewDataSource
extension USMainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let data = searchResultData, let results = data.results else {
            return 0
        }
        return results.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView
            .dequeueReusableCell(withReuseIdentifier: cellID,
                                 for: indexPath) as? CollectionViewCell else {
            return UICollectionViewCell()
        }

        return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: headerID,
                                                                     for: indexPath)
        header.addSubview(searchBar)

        return header
    }
}

// MARK: - UICollectionViewDelegate
extension USMainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CollectionViewCell,
            let urls = searchResultData?
                .results?[indexPath.item]
                .urls else {
            return
        }

        cell.setupData(with: urls)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension USMainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 40)
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
}
