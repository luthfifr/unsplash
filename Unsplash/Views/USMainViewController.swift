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
    typealias Constants = USConstants.Main

    private var viewModel: USMainViewModel!
    private let disposeBag = DisposeBag()
    private var searchResultData: USResponse? {
        didSet {
            guard let data = searchResultData else {
                return
            }
            switch data.status {
            case .success:
                if resultDataArr == nil {
                    resultDataArr = data.results
                    scrollToTop()
                } else {
                    guard let dataResults = data.results else {
                        return
                    }
                    for result in dataResults {
                        resultDataArr?.append(result)
                    }
                }
                collectionView.reloadData()
            case .failure:
                var errModel = USServiceError()
                errModel.responseString = data.responseString
                showError(errModel)
            }
        }
    }

    private var resultDataArr: [USResult]?

    private var collectionView: UICollectionView!
    private var searchController: UISearchController!

    private let cellID = String(describing: CollectionViewCell.self)
    private let headerID = String(describing: CollectionViewHeader.self)
    private var lastContentOffset: CGFloat = 0
    private var isScrollingDown = false

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

        title = "Search Image"

        setupViews()
        setupEvents()
    }
}

// MARK: - Private Methods
extension USMainViewController {
    private func setupViews() {
        setupSearchController()
        setupCollectionView()
        implementCustomDelegate()
    }

    private func setupEvents() {
        viewModel.uiEvents.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .requestDataSuccess(let isNewQuery):
                if isNewQuery {
                    self.resultDataArr = nil
                    self.searchResultData = nil
                }
                self.searchResultData = self.viewModel.responseData
            case .requestDataFailure(let error):
                self.showError(error)
            default: break
            }
        }).disposed(by: disposeBag)
    }

    private func setupSearchController() {
        if searchController == nil {
            let searchController = UISearchController(searchResultsController: nil)
            searchController.obscuresBackgroundDuringPresentation = false
            searchController.searchBar.placeholder = "Type here..."
            searchController.searchBar.delegate = self
            searchController.searchBar.searchTextField.delegate = self
            navigationItem.searchController = searchController
            definesPresentationContext = true
        }
    }

    private func setupCollectionView() {
        if collectionView == nil {
            let customLayout = USCustomLayout()
//            customLayout.delegate = self
            collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: customLayout)
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

    private func implementCustomDelegate() {
        if let layout = collectionView?.collectionViewLayout as? USCustomLayout {
          layout.delegate = self
        }
    }

    func scrollToTop() {
        DispatchQueue.main.async {
             if let results = self.resultDataArr,
                results.count > 0 {
                let indexPath = IndexPath(row: 0, section: 0)
                self.collectionView.scrollToItem(at: indexPath,
                                                 at: .top,
                                                 animated: true)

             }
         }
    }

    private func showError(_ error: USServiceError?) {
        var alertModel = UIAlertModel(style: .alert)
        guard let error = error else {
            return
        }
        alertModel.message = error.responseString ?? String()
        alertModel.title = "Request Data Failure"
        alertModel.actions = [UIAlertActionModel(title: "OK", style: .cancel)]
        self.showAlert(with: alertModel)
        .asObservable()
        .subscribe(onNext: { selectedActionIdx in
        //handle the action here
            print("alert action index = \(selectedActionIdx)")
        }).disposed(by: self.disposeBag)
    }
}

// MARK: - UISearchBarDelegate
extension USMainViewController: UISearchBarDelegate {
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        viewModel
            .viewModelEvents
            .onNext(.getPhotoData(searchBar.text))
    }
}

extension USMainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UICollectionViewDataSource
extension USMainViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let results = resultDataArr else {
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
}

extension USMainViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.lastContentOffset = scrollView.contentOffset.y
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffset < scrollView.contentOffset.y {
            isScrollingDown = true
        } else if self.lastContentOffset > scrollView.contentOffset.y {
            isScrollingDown = false
        }
    }
}

// MARK: - UICollectionViewDelegate
extension USMainViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? CollectionViewCell,
            let results = resultDataArr,
            let urls = results[indexPath.item].urls else {
            return
        }

        cell.setupData(with: urls)

        if isScrollingDown && indexPath.item == results.count - 1 {
            viewModel.viewModelEvents.onNext(.loadMorePage)
        }
    }
}

extension USMainViewController: USCustomLayoutDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat {
    guard let item = resultDataArr?[indexPath.item],
        let itemWidth = item.width, let itemHeight = item.height else {
        return 0
    }

    let insets = collectionView.contentInset
    let cellWidth = (collectionView.bounds.width - (insets.left + insets.right)) / CGFloat(Constants.numberOfColumn)
    let aspectRatio: CGFloat = CGFloat((itemHeight/itemWidth))

    return aspectRatio * cellWidth
  }
}
