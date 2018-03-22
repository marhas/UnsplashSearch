//
//  LinksParser.swift
//  UnsplashSearch
//
//  Created by Marcel Hasselaar on 2018-03-18.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import Foundation

func parseLinks(from linkString: String) -> [String: URL] {
    let linkParts = linkString.split(separator: ",")
    let parsedLinkParts: [String: URL] = linkParts.reduce(into: Dictionary<String, URL>()) { result, substring in
        let parts = substring.split(separator: ";")
        guard parts.count == 2 else { return }
        let urlString = parts[0].trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "<>"))
        guard   let url = URL(string: urlString),
            let rel = parts[1].split(separator: "\"").dropFirst().first?.trimmingCharacters(in: .whitespacesAndNewlines)
            else { return }
        result[String(rel)] = url
    }
    return parsedLinkParts
}
