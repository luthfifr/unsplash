//
//  USConstants.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import Foundation
import UIKit

struct USConstants {
    struct API {
        static let accessKey = "d8a272c480b258b875d82f4062d6c52e4ae7f4b4656add778d71e9b638b2f8be"
        static let url = "https://api.unsplash.com/"
        static let path = "search/photos"
    }

    struct ParamKeys {
        static let page = "page"
        static let query = "query"
    }

    struct ParamValues {
        static let defaultPage = 1
    }

    struct MainVC {
        static let cellSpacing: CGFloat = 10
    }
}
