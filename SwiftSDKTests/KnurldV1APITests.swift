//
//  SwiftSDKTests.swift
//  SwiftSDKTests
//
//  Created by Ryan Conway on 7/7/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftSDK


let API_CALL_TIMEOUT: NSTimeInterval = 3 // seconds
class AuthSpec: QuickSpec {
    let api = KnurldV1API()
    
    override func spec() {
        it("returns a token when given valid credentials") {
            var accessToken: String? = nil
            
            self.api.authorize(clientID: TEST_CLIENT_ID, clientSecret: TEST_CLIENT_SECRET,
                          successHandler: { token in accessToken = token },
                          failureHandler: { error in print("ERROR: \(error)") })
            
            expect(accessToken).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
        }
        
        it("fails when given bad credentials") {
            var apiError: HTTPRequestError? = nil
            
            self.api.authorize(clientID: "asdf", clientSecret: "asdf",
                               successHandler: { _ in () },
                               failureHandler: { error in apiError = error })
            
            expect(apiError).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
        }
    }
}

// Shared because everything else shares an auth token
class EverythingButAuthSpec: QuickSpec {
    override func spec() {
        let api = KnurldV1API()
        
        var accessToken: String = ""
        api.authorize(clientID: TEST_CLIENT_ID, clientSecret: TEST_CLIENT_SECRET,
                      successHandler: { token in accessToken = token },
                      failureHandler: { error in print("ERROR: \(error)") })
        
        beforeEach {
            expect(accessToken).toEventuallyNot(beEmpty(), timeout: API_CALL_TIMEOUT)
        }
        
        describe("the get status API") {
            it("returns all expected variables on success") {
                var href: String? = nil
                var name: String? = nil
                var version: String? = nil
                
                api.getServiceStatus(developerID: TEST_DEVELOPER_ID, authorization: accessToken,
                                     successHandler: { (hr, nm, ver) in href = hr; name = nm; version = ver },
                                     failureHandler: { error in print("ERROR: \(error)") })
                
                expect(href).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
                expect(name).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
                expect(version).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        /*
        describe("the create app model API") {
            it("returns all expected variables on success") {
                var href: String? = nil
                
                let params = AppModelParams(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                
                createAppModel(developerID: TEST_DEVELOPER_ID, authorization: accessToken, params: params,
                               onSuccess: { hr in href = hr },
                               onFailure: { error in print("ERROR: \(error)")})
                
                expect(href).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
         */
        
        /*
        describe("the get app model API") {
            it("returns at least one app model on success") {
                var items: [AppModelParams]? = nil
                
                getAllAppModels(developerID: TEST_DEVELOPER_ID, authorization: accessToken,
                                onSuccess: {
            }
        }
 */
    }
}