//
//  SwiftSDKTests.swift
//  SwiftSDKTests
//
//  Created by Ryan Conway on 7/7/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Quick
import Nimble
import SwiftSDK

class SwiftSDKTests: QuickSpec {
    
    override func spec() {
        /*
        describe("SwiftSDK") {
            it("works") {
                expect(true).to(beTrue())
            }
        }
        */
        
        var accessToken: String? = nil
        
        authorize(clientID: TEST_CLIENT_ID, clientSecret: TEST_CLIENT_SECRET,
                  onSuccess: { token in accessToken = token },
                  onFailure: { error in print("Error: \(error)") })
        
        expect(accessToken).toEventuallyNot(beNil())
    }
 
}
