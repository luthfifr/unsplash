//
//  USTarget.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import Moya

enum USTarget {
    case getPhotoData(_ query: String?)
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
        case .getPhotoData(let query):
            return .requestParameters(parameters: getParameters(query),
                                      encoding: URLEncoding.queryString)
        }
    }

    var sampleData: Data {
        return Data()
    }

    var headers: [String: String]? {
        return nil
    }
}

extension USTarget {
    func getParameters(_ query: String?) -> [String: Any] {
        var params = [String: Any]()

        params[USConstants.ParamKeys.page] = USConstants.ParamValues.defaultPage
        params[USConstants.ParamKeys.query] = query ?? String()

        return params
    }
}
