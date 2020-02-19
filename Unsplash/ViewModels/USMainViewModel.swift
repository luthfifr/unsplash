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
    case requestDataFailure(_ error: USServiceError?)
    case requestDataSuccess

    static func == (lhs: USMainViewModelEvent, rhs: USMainViewModelEvent) -> Bool {
        switch (lhs, rhs) {
        case (getPhotoData, getPhotoData),
             (requestDataFailure, requestDataFailure):
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
                self.getPhotoData(query)
            default: break
            }
        }).disposed(by: disposeBag)
    }

    private func getPhotoData(_ query: String?) {
        service.getPhotoData(query)
            .asObservable()
            .subscribe(onNext: { [weak self] event in
                guard let `self` = self else { return }
                switch event {
                case .waiting: break
                case .failed(let error):
                    self.uiEvents
                        .onNext(.requestDataFailure(error))
                case .succeeded(let response):
                    self.responseData = response
                    self.uiEvents
                        .onNext(.requestDataSuccess)
                }
            }).disposed(by: disposeBag)
    }
}
