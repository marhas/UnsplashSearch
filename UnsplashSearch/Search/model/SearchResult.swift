//
//  SearchResult.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-18.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import Foundation

struct SearchResult: Codable {
    let total: Int
    let totalPages: Int
    let images: [Image]?
    let previousResult: URL?
    let nextResult: URL?
    let firstResult: URL?
    let lastResult: URL?

    static let linksCodingUserInfoKey = CodingUserInfoKey(rawValue: "links")!

    enum CodingKeys: String, CodingKey {
        case total = "total"
        case totalPages = "total_pages"
        case images = "results"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        total = try container.decode(Int.self, forKey: .total)
        totalPages = try container.decode(Int.self, forKey: .totalPages)
        images = try? container.decode(Array<Image>.self, forKey: .images)
        if let linksString = decoder.userInfo[SearchResult.linksCodingUserInfoKey] as? String {
            let links = parseLinks(from: linksString)
            previousResult = links["prev"]
            nextResult = links["next"]
            firstResult = links["first"]
            lastResult = links["last"]
        } else {
            previousResult = nil
            nextResult = nil
            firstResult = nil
            lastResult = nil
        }
    }
}
