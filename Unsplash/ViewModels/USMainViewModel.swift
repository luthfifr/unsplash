//
//  USMainViewModel.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import Foundation
import RxSwift

enum USMainViewModelEvent: Equatable {
    case getPhotoData(_ query: String?)
    case loadMorePage
    case requestDataFailure(_ error: USServiceError?)
    case requestDataSuccess(_ isNewQuery: Bool)

    static func == (lhs: USMainViewModelEvent, rhs: USMainViewModelEvent) -> Bool {
        switch (lhs, rhs) {
        case (getPhotoData, getPhotoData),
             (loadMorePage, loadMorePage),
             (requestDataFailure, requestDataFailure),
             (requestDataSuccess, requestDataSuccess):
            return true
        default: return false
        }
    }
}

protocol USMainViewModelType {
    var uiEvents: PublishSubject<USMainViewModelEvent> { get }
    var viewModelEvents: PublishSubject<USMainViewModelEvent> { get }
    var responseData: USResponse? { get }
}

final class USMainViewModel: USMainViewModelType {
    let uiEvents = PublishSubject<USMainViewModelEvent>()
    let viewModelEvents = PublishSubject<USMainViewModelEvent>()
    var responseData: USResponse?

    private let disposeBag = DisposeBag()
    private let service = USService()

    private var currentQuery: String?
    private var currentPage: Int?

    init() {
        setupEvents()
    }
}

// MARK: - Private Methods
extension USMainViewModel {
    private func setupEvents() {
        viewModelEvents.subscribe(onNext: { [weak self] event in
            guard let `self` = self else { return }
            switch event {
            case .getPhotoData(let query):
                self.getPhotoData(query, true)
            case .loadMorePage:
                self.loadMorePage()
            default: break
            }
        }).disposed(by: disposeBag)
    }

    private func getPhotoData(_ query: String?,
                              _ isNewQuery: Bool,
                              _ page: Int? = 1) {
        currentPage = page
        currentQuery = query

        service.getPhotoData(currentQuery, currentPage)
            .asObservable()
            .subscribe(onNext: { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .waiting: break
                case .failed(let error):
                    self.uiEvents
                        .onNext(.requestDataFailure(error))
                case .succeeded(let response):
                    if isNewQuery {
                        self.responseData = nil
                    }
                    self.responseData = response
                    self.uiEvents
                        .onNext(.requestDataSuccess(isNewQuery))
                }
            }).disposed(by: disposeBag)
    }

    private func loadMorePage() {
        guard let data = responseData,
            let totalPages = data.totalPages,
            var currPage = currentPage else { return }
        if currPage < totalPages {
            currPage += 1
            getPhotoData(currentQuery, false, currPage)
        }
    }
}
