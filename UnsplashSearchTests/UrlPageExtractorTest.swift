//
//  UrlPageExtractorTest.swift
//  UnsplashSearchTests
//
//  Created by Marcel Hasselaar on 2018-03-19.
//  Copyright © 2018 Unbad Apps Stockholm HB. All rights reserved.
//

import XCTest
@testable import UnsplashSearch

class UrlpageExtractorTest: XCTestCase {

    func testExtractExistingPage() {
        let testUrlWithPage = URL(string:"https://api.unsplash.com/search/photos?page=621&query=beach")!
        XCTAssertTrue(testUrlWithPage.page == 621)
        let testUrlWithPageAtEnd = URL(string:"https://api.unsplash.com/search/photos?query=beach&page=622")!
        XCTAssertTrue(testUrlWithPageAtEnd.page == 622)
    }

    func testExtractExistingButInvalidPage() {
        let testUrlWithPage = URL(string:"https://api.unsplash.com/search/photos?page=abc&query=beach")!
        XCTAssertTrue(testUrlWithPage.page == 1)
    }

    func testExtractNonexistingPage() {
        let testUrlWithoutPage = URL(string:"https://api.unsplash.com/search/photos?query=beach")!
        XCTAssertTrue(testUrlWithoutPage.page == 1)
    }
}
