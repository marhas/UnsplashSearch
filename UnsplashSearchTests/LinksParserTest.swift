//
//  LinksParserTest.swift
//  UnsplashSearchTests
//
//  Created by Marcel Hasselaar on 2018-03-18.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import XCTest
@testable import UnsplashSearch

class LinksParserTest: XCTestCase {
    
    func testLinksParsingHappyPath() {
        let linkString = """
            <https://api.unsplash.com/search/photos?page=1&query=beach>;    rel="first",
            <https://api.unsplash.com/search/photos?page=1&query=beach>; rel="prev   ",
            <https://api.unsplash.com/search/photos?page=621&query=beach>; rel="last",
            <https://api.unsplash.com/search/photos?page=3&query=beach>; rel="next"
        """
        let parsedLinks = parseLinks(from: linkString)
        XCTAssertEqual(parsedLinks["first"], URL(string: "https://api.unsplash.com/search/photos?page=1&query=beach")!)
        XCTAssertEqual(parsedLinks.count, 4)
    }

    func testThatLinksParsingIgnoresBadUrls() {
        let linkString = """
            ;    rel="first",
            <https://api.unsplash.com/search/photos?page=1&query=beach>; rel="prev   ",
            <https://api.unsplash.com/search/photos?page=621&query=beach>; rel="last",
            <https://api.unsplash.com/search/photos?page=3&query=beach>; rel="next"
        """
        let parsedLinks = parseLinks(from: linkString)
        XCTAssertEqual(parsedLinks.count, 3)
    }
}
