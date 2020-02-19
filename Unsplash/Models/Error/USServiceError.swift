//
//  USServiceError.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import Foundation
import HandyJSON
import Moya

enum USResponseStatus: String {
    case success
    case failure
}

struct USServiceError: HandyJSON {
    var responseString: String?
    var status: USResponseStatus
    var error: MoyaError?

    init() {
        status = .failure
        error = nil
        responseString = nil
    }
}

extension USServiceError: Equatable {
    public static func == (lhs: USServiceError, rhs: USServiceError) -> Bool {
        return lhs.responseString == rhs.responseString &&
            lhs.status == rhs.status
    }
}
