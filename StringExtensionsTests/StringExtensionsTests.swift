//
//  StringExtensionsTests.swift
//  StringExtensionsTests
//
//  Created by Juergen Baumann on 01.04.18.
//  Copyright © 2018 Juergen Baumann. All rights reserved.
//

import Cocoa
import XCTest

@testable import ImageUtil

class StringExtensionsTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
  
  func test_substringFromIntIndex() {
    //
    XCTAssertEqual("hallo".substringFromIntIndex(0), "hallo", "Pass index 0")
    XCTAssertEqual("hallo".substringFromIntIndex(2), "llo", "Pass index 2")
    XCTAssertEqual("hallo".substringFromIntIndex(10), "hallo", "Pass index 10")
    
  }
    
  func test_substringWithPattern() {
    //
    XCTAssertEqual("hallo".substringWithPattern("[1-2][0-9]{3}"), nil, "Pass nil")
    XCTAssertEqual("2018".substringWithPattern("[1-2][0-9]{3}"), "2018", "Pass 2018")
    XCTAssertEqual("2018_hallo".substringWithPattern("[1-2][0-9]{3}"), "2018", "Pass 2018")
  }
  
  func test_parseDateFromFileName() {
    //
    var s:String = "2018_hallo"
    XCTAssert(s.parseDateFromFileName() == "2018".parseDate("yyyy"), "Pass 2018")
    s = "2018-02_hallo"
    XCTAssert(s.parseDateFromFileName() == "2018-02".parseDate("yyyy-MM"), "Pass 02.2018")
    s = "2018-02-26_hallo"
    XCTAssert(s.parseDateFromFileName() == "2018-02-26".parseDate("yyyy-MM-dd"), "Pass 26.02.2018")
    s = "2018-02-26_10-56_hallo"
    XCTAssert(s.parseDateFromFileName() == "2018-02-26_10-56".parseDate("yyyy-MM-dd_hh-mm"), "Pass 26.02.2018 10:56")
  }
    
}
