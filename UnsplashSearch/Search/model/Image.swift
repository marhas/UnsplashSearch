//
//  SearchResource.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-18.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import Foundation

struct Image: Codable {
    let id: String
    let thumbnailUrl: URL
    let imageUrl: URL

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case urls = "urls"
    }

    enum UrlsCodingKeys: String, CodingKey {
        case thumbnailUrl = "thumb"
        case imageUrl = "regular"
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        var urlsContainer = container.nestedContainer(keyedBy: UrlsCodingKeys.self, forKey: .urls)
        try urlsContainer.encode(thumbnailUrl, forKey: .thumbnailUrl)
        try urlsContainer.encode(imageUrl, forKey: .imageUrl)
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let urlsContainer = try container.nestedContainer(keyedBy: UrlsCodingKeys.self, forKey: .urls)
        self.id = try container.decode(String.self, forKey: .id)
        self.imageUrl = try urlsContainer.decode(URL.self, forKey: .imageUrl)
        self.thumbnailUrl = try urlsContainer.decode(URL.self, forKey: .thumbnailUrl)
    }
}
