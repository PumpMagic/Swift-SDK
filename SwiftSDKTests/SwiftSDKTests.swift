//
//  SwiftSDKTests.swift
//  SwiftSDKTests
//
//  Created by Ryan Conway on 7/7/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import XCTest
import SwiftSDK

class SwiftSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        //@todo actually implement an asynchronous test; for now, this just verifies linking
        authorize(clientID: TEST_CLIENT_ID, clientSecret: TEST_CLIENT_SECRET,
                  onSuccess: { accessToken in print("Application got token: \(accessToken)") },
                  onFailure: { error in print("Application got error: \(error)") })
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
