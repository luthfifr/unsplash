//
//  USResponse.swift
//  Unsplash
//
//  Created by Luthfi Fathur Rahman on 19/02/20.
//  Copyright © 2020 StandAlone. All rights reserved.
//

import Foundation
import HandyJSON
import Moya

struct USResponse: HandyJSON {
    var responseString: String?
    var status: USResponseStatus
    var moyaError: MoyaError?

    var total: Int?
    var totalPages: Int?
    var results: [USResult]?

    init() {
        status = .failure
        moyaError = nil
        responseString = nil
    }

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.totalPages <-- "total_pages"
    }
}

struct USResult: HandyJSON {
    var resultId: String?
    var createdAt: String?
    var width: Double?
    var height: Double?
    var color: String?
    var likes: Int?
    var likedByUser: Bool = false
    var description: String?
    var user: USResultUser?
//        var current_user_collection: [[String: Any]]?
    var urls: USResultURL?
    var links: USResultLink?

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.resultId <-- "id"
        mapper <<<
            self.createdAt <-- "created_at"
        mapper <<<
            self.likedByUser <-- "liked_by_user"
    }
}

struct USResultUser: HandyJSON {
    var resultUserId: String?
    var username: String?
    var name: String?
    var firstName: String?
    var lastName: String?
    var instagramUsername: String?
    var twitterUsername: String?
    var portfolioLink: String?
    var links: USResultLink?

    mutating func mapping(mapper: HelpingMapper) {
        mapper <<<
            self.resultUserId <-- "id"
        mapper <<<
            self.firstName <-- "first_name"
        mapper <<<
            self.lastName <-- "last_name"
        mapper <<<
            self.instagramUsername <-- "instagram_username"
        mapper <<<
            self.twitterUsername <-- "twitter_username"
        mapper <<<
            self.portfolioLink <-- "portfolio_link"
    }
}

struct USResultLink: HandyJSON {
    var `self`: String?
    var html: String?
    var download: String?
    var photos: String?
    var likes: String?
}

struct USResultURL: HandyJSON {
    var raw: String?
    var full: String?
    var regular: String?
    var small: String?
    var thumb: String?
}
