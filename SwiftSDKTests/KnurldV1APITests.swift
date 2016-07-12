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


let API_CALL_TIMEOUT: NSTimeInterval = 5 // seconds
let validOAuthCredentials = ClientCredentials(clientID: TEST_CLIENT_ID, clientSecret: TEST_CLIENT_SECRET)

extension AppModel: Equatable {}
func ==(lhs: AppModel, rhs: AppModel) -> Bool {
    if lhs.enrollmentRepeats == rhs.enrollmentRepeats &&
        lhs.vocabulary == rhs.vocabulary &&
        lhs.verificationLength == rhs.verificationLength
    {
        return true
    }
    
    return false
}

class AuthSpec: QuickSpec {
    let api = KnurldV1API()
    let invalidCredentials = ClientCredentials(clientID: "asdf", clientSecret: "asdf")
    
    override func spec() {
        it("returns a response when given valid credentials") {
            var response: AuthorizationResponse? = nil
            
            self.api.authorize(credentials: validOAuthCredentials,
                          successHandler: { resp in response = resp },
                          failureHandler: { error in print("ERROR: \(error)") })
            
            expect(response).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
        }
        
        it("fails when given bad credentials") {
            var apiError: HTTPRequestError? = nil
            
            self.api.authorize(credentials: self.invalidCredentials,
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
        
        var knurldCredentials: KnurldCredentials = KnurldCredentials(developerID: "", authorization: "")
        
        api.authorize(credentials: validOAuthCredentials,
                      successHandler: { resp in
                        knurldCredentials = KnurldCredentials(developerID: TEST_DEVELOPER_ID, authorizationResponse: resp) },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        beforeEach {
            expect(knurldCredentials.developerID).toEventuallyNot(beEmpty(), timeout: API_CALL_TIMEOUT)
            expect(knurldCredentials.authorization).toEventuallyNot(beEmpty(), timeout: API_CALL_TIMEOUT)
        }
        
        describe("the get status API") {
            it("returns a response when called properly") {
                var status: ServiceStatus? = nil
                
                api.getServiceStatus(credentials: knurldCredentials,
                                     successHandler: { stat in status = stat },
                                     failureHandler: { error in print("ERROR: \(error)") })
                
                expect(status).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the create app model API") {
            it("returns a response when called properly") {
                let model = AppModel(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                var locator: AppModelLocator? = nil
                
                api.createAppModel(credentials: knurldCredentials,
                                   model: model,
                                   successHandler: { loc in locator = loc },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                expect(locator).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get app models API") {
            it("returns at least one app model on success") {
                var models: [AppModel]? = nil
                
                api.getAppModels(credentials: knurldCredentials,
                                 successHandler: { mdls in models = mdls },
                                 failureHandler: { error in print("ERROR: \(error)")})
                
                expect(models).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get app model API") {
            it("works on a freshly created app model") {
                var locator: AppModelLocator? = nil
                
                let modelUp = AppModel(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                var modelDown: AppModel? = nil
                
                api.createAppModel(credentials: knurldCredentials,
                                   model: modelUp,
                                   successHandler: { loc in locator = loc },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                sleep(UInt32(API_CALL_TIMEOUT))
                guard let loc = locator else {
                    fail("Unable to create app model for retrieving")
                    return
                }
                
                api.getAppModel(credentials: knurldCredentials,
                                locator: loc,
                                successHandler: { mdl in modelDown = mdl },
                                failureHandler: { error in print("ERROR: \(error)") })
                sleep(UInt32(API_CALL_TIMEOUT))
                
                guard let mdl = modelDown else {
                    fail("Get app model failed")
                    return
                }
                
                expect(mdl).to(equal(modelUp))
            }
        }
        
        describe("the update app model API") {
            it("works on a freshly created app model") {
                var locator: AppModelLocator? = nil
                
                var modelUp = AppModel(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                
                api.createAppModel(credentials: knurldCredentials,
                                   model: modelUp,
                                   successHandler: { loc in locator = loc },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                sleep(UInt32(API_CALL_TIMEOUT))
                guard let loc = locator else {
                    fail("Unable to create app model for retrieving")
                    return
                }
                
                modelUp.enrollmentRepeats = 5
                
                var modelDown: AppModel? = nil
                api.updateAppModel(credentials: knurldCredentials, locator: loc, model: modelUp,
                                   successHandler: { mdl in modelDown = mdl },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                sleep(UInt32(API_CALL_TIMEOUT))
                guard let mdlDwn = modelDown else {
                    fail("Unable to update app model")
                    return
                }
                
                expect(mdlDwn).to(equal(modelUp))
            }
        }
        
        describe("the delete app model API") {
            it("works on a freshly created app model") {
                var locator: AppModelLocator? = nil
                
                let model = AppModel(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                
                api.createAppModel(credentials: knurldCredentials,
                                   model: model,
                                   successHandler: { loc in locator = loc },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                sleep(UInt32(API_CALL_TIMEOUT))
                guard let loc = locator else {
                    fail("Unable to create app model for deleting")
                    return
                }
                
                var deleted: Bool = false
                
                api.deleteAppModel(credentials: knurldCredentials, locator: loc,
                                   successHandler: { deleted = true },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT)
            }
        }

    }
}