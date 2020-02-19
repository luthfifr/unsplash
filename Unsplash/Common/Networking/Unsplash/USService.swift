//
//  USService.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import RxSwift
import Moya

protocol USCurrencyLayerType {
    func getPhotoData(_ query: String?) -> Observable<USNetworkEvent<USResponse>>
}

struct USCurrencyLayerService: USCurrencyLayerType {
    private let provider: MoyaProvider<USTarget>

    init() {
        provider = CCMoyaProvider<USTarget>()
    }

    init(provider: CCMoyaProvider<USTarget>) {
        self.provider = provider
    }

    func getPhotoData(_ query: String?) -> Observable<USNetworkEvent<USResponse>> {
        return provider.rx.request(.getPhotoData(query))
            .parseResponse({ (responseString: String) in
                guard var response = USResponse.deserialize(from: responseString) else {
                    return USResponse()
                }

                response.status = .success
                response.responseString = responseString

                return response
            })
            .mapFailures { error in
                return .failed(error)
            }
    }
}
