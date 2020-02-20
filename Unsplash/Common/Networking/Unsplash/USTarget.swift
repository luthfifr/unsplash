//
//  USTarget.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import Moya

enum USTarget {
    case getPhotoData(_ query: String?, _ page: Int?)
}

extension USTarget: TargetType {
    var baseURL: URL {
        switch self {
        case .getPhotoData:
            return URL(string: USConstants.API.url) ?? URL(string: "")!
        }
    }

    var path: String {
        switch self {
        case .getPhotoData:
            return USConstants.API.path
        }
    }

    var method: Moya.Method {
        return .get
    }

    var task: Task {
        switch self {
        case let .getPhotoData(query, page):
            return .requestParameters(parameters: getParameters(query, page),
                                      encoding: URLEncoding.queryString)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return ["Authorization": "Client-ID \(USConstants.API.accessKey)"]
    }
}

extension USTarget {
    func getParameters(_ query: String?, _ page: Int?) -> [String: Any] {
        var params = [String: Any]()

        params[USConstants.ParamKeys.page] = page ?? USConstants.ParamValues.defaultPage
        params[USConstants.ParamKeys.query] = query ?? String()

        return params
    }
}
