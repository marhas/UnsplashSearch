//
//  URL+util.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-19.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import Foundation

extension URL {
    var page: Int {
        let components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        let pageNumberString = components?.queryItems?.first(where: { queryItem in
            return queryItem.name == "page"
        })?.value ?? "1"
        return Int(pageNumberString) ?? 1
    }
}
