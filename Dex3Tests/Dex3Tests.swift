//
//  Dex3Tests.swift
//  Dex3Tests
//
//  Created by Atacan Sevim on 8.11.2023.
//

import XCTest

final class Dex3Tests: XCTestCase {
    
    static var counter = 0

    override class func setUp() {
        Dex3Tests.counter += 1
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        print("First one run: \(Dex3Tests.counter) ")
    }
    
    func testExample1() throws {
        print("Second one run:  \(Dex3Tests.counter)")
    }
    
    func testExample2() throws {
        print("Third one run: \(Dex3Tests.counter)")
    }

}
