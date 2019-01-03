//
//  ArrayHelpersTests.swift
//  DiaryTests
//
//  Created by Erik Carlson on 1/3/19.
//  Copyright © 2019 Round and Rhombus. All rights reserved.
//

import XCTest
@testable import Diary

class ArrayHelpersTests: XCTestCase {
    let intArray = [0, 1, 2]

    override func setUp() {
        
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testClampIndexBelow() {
        let index = intArray.clampIndex(-1)
        XCTAssertEqual(index, 0)
    }
    
    func testClampIndexAbove() {
        let index = intArray.clampIndex(3)
        XCTAssertEqual(index, 2)
    }
}
