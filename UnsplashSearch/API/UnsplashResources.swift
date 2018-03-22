//
//  Resource.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-18.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import Foundation

struct Resource<T> {
    let url: URL
    let parse: (_ data: Data, _ response: URLResponse) -> T?
}

struct SearchResources {

    static let numberOfThumbnailsPerPage = 30

    static func createSearchResource(for searchString: String) -> Resource<SearchResult>? {
        let encodedSearchString = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? ""
        let searchUrlString = "https://api.unsplash.com/search/photos?per_page=\(numberOfThumbnailsPerPage)&query=\(encodedSearchString)"
        guard let searchUrl = URL(string: searchUrlString) else {
            return nil
        }
        return createSearchResource(url: searchUrl)
    }

    static func createSearchResource(url: URL) -> Resource<SearchResult> {
        return Resource<SearchResult>(url: url) { data, response in
            guard let httpResponse = response as? HTTPURLResponse else { return nil }

            let jsonDecoder = JSONDecoder()
            if let links = httpResponse.allHeaderFields["Link"] as? String {
                jsonDecoder.userInfo = [SearchResult.linksCodingUserInfoKey: links]
            }
            let result: SearchResult?
            do {
                result = try jsonDecoder.decode(SearchResult.self, from: data)
            } catch {
                result = nil
                print("Parsing error: \(error)")
            }
            return result
        }
    }
}
