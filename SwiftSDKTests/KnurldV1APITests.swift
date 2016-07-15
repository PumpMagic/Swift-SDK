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

extension ResourceLocator: Equatable {}
func ==<T>(lhs: ResourceLocator<T>, rhs: ResourceLocator<T>) -> Bool {
    if lhs.href == rhs.href {
        return true
    }
    
    return false
}

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

func randomAlphanumericString(length length: Int) -> String {
    let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let allowedCharsCount = UInt32(allowedChars.characters.count)
    var randomString = ""
    
    for _ in (0..<length) {
        let randomNum = Int(arc4random_uniform(allowedCharsCount))
        let newCharacter = allowedChars[allowedChars.startIndex.advancedBy(randomNum)]
        randomString += String(newCharacter)
    }
    
    return randomString
}


class AuthorizationSpec: QuickSpec {
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

class StatusSpec: QuickSpec {
    override func spec() {
        let api = KnurldV1API()
        
        var knurldCredentials: KnurldCredentials!
        api.authorize(credentials: validOAuthCredentials,
                      successHandler: { resp in
                        knurldCredentials = KnurldCredentials(developerID: TEST_DEVELOPER_ID, authorizationResponse: resp) },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        describe("the get status API") {
            it("returns a response when called properly") {
                var status: ServiceStatus? = nil
                
                api.getServiceStatus(credentials: knurldCredentials,
                                     successHandler: { stat in status = stat },
                                     failureHandler: { error in print("ERROR: \(error)") })
                
                expect(status).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
    }
}

class AppModelsSpec: QuickSpec {
    override func spec() {
        let api = KnurldV1API()
        
        var knurldCredentials: KnurldCredentials!
        api.authorize(credentials: validOAuthCredentials,
                      successHandler: { resp in
                        knurldCredentials = KnurldCredentials(developerID: TEST_DEVELOPER_ID, authorizationResponse: resp) },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        describe("the create app model API") {
            it("returns a good response when called properly") {
                let request = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                var locator: ResourceLocator<AppModel>? = nil
                
                api.appModels.create(credentials: knurldCredentials,
                                            request: request,
                                            successHandler: { loc in locator = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                
                expect(locator).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get app models API") {
            it("returns success when given good parameters") {
                var page: AppModelPage? = nil
                
                api.appModels.getPage(credentials: knurldCredentials,
                                      successHandler: { pg in page = pg },
                                      failureHandler: { error in print("ERROR: \(error)")})
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get app model API") {
            it("works on a freshly created app model") {
                let createRequest = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                var locator: ResourceLocator<AppModel>! = nil
                
                api.appModels.create(credentials: knurldCredentials,
                                            request: createRequest,
                                            successHandler: { loc in locator = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator == nil {
                    fail("Unable to create app model for retrieving")
                    return
                }
                
                var model: AppModel! = nil
                api.appModels.get(credentials: knurldCredentials,
                                         locator: locator,
                                         successHandler: { mdl in model = mdl },
                                         failureHandler: { error in print("ERROR: \(error)") })
                sleep(UInt32(API_CALL_TIMEOUT))
                if model == nil {
                    fail("Get app model failed")
                    return
                }
                
                expect(model.enrollmentRepeats).to(equal(createRequest.enrollmentRepeats))
            }
        }
        
        describe("the update app model API") {
            it("works on a freshly created app model") {
                let initialEnrollmentRepeats = 3
                let targetEnrollmentRepeats = 5
                
                // Create an app model
                var locator1: ResourceLocator<AppModel>! = nil
                let createRequest = AppModelCreateRequest(enrollmentRepeats: initialEnrollmentRepeats, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                api.appModels.create(credentials: knurldCredentials,
                                            request: createRequest,
                                            successHandler: { loc in locator1 = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator1 == nil {
                    fail("Unable to create app model for retrieving")
                    return
                }
                
                // Update the app model
                var locator2: ResourceLocator<AppModel>! = nil
                let request = AppModelUpdateRequest(enrollmentRepeats: targetEnrollmentRepeats, threshold: nil, verificationLength: nil)
                api.appModels.update(credentials: knurldCredentials,
                                            locator: locator1,
                                            request: request,
                                            successHandler: { loc in locator2 = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator2 == nil {
                    fail("Unable to update app model")
                    return
                }
                
                // Make sure the locator returned by update matches that returned by create
                expect(locator1).to(equal(locator2))
                
                // Retrieve the (hopefully updated) app model
                var modelRetrieved: AppModel! = nil
                api.appModels.get(credentials: knurldCredentials,
                                         locator: locator2,
                                         successHandler: { mdl in modelRetrieved = mdl },
                                         failureHandler: { error in print("ERROR: \(error)") })
                sleep(UInt32(API_CALL_TIMEOUT))
                if modelRetrieved == nil {
                    fail("unable to retrieve updated app model")
                    return
                }
                
                // Verify that the app model was updated
                expect(modelRetrieved.enrollmentRepeats).to(equal(targetEnrollmentRepeats))
            }
        }
        
        describe("the delete app model API") {
            it("works on a freshly created app model") {
                // Create an app model
                var locator: ResourceLocator<AppModel>! = nil
                let request = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                api.appModels.create(credentials: knurldCredentials,
                                            request: request,
                                            successHandler: { loc in locator = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator == nil {
                    fail("Unable to create app model for deleting")
                    return
                }
                
                // Delete the app model
                var deleted: Bool = false
                api.appModels.delete(credentials: knurldCredentials, locator: locator,
                                            successHandler: { deleted = true },
                                            failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT)
            }
        }

    }
}

class ConsumersSpec: QuickSpec {
    override func spec() {
        let api = KnurldV1API()
        
        var knurldCredentials: KnurldCredentials!
        api.authorize(credentials: validOAuthCredentials,
                      successHandler: { resp in
                        knurldCredentials = KnurldCredentials(developerID: TEST_DEVELOPER_ID, authorizationResponse: resp) },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        describe("the create consumer API") {
            it("returns a good response when called properly") {
                let username = randomAlphanumericString(length: 10)
                let password = randomAlphanumericString(length: 10)
                let gender = "M"
                
                let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
                var locator: ResourceLocator<Consumer>? = nil
                
                api.consumers.create(credentials: knurldCredentials,
                                            request: consumerCreateRequest,
                                            successHandler: { loc in locator = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                
                expect(locator).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get consumers API") {
            it("returns success when given good parameters") {
                var page: ConsumerPage? = nil
                
                api.consumers.getPage(credentials: knurldCredentials,
                                      successHandler: { pg in page = pg },
                                      failureHandler: { error in print("ERROR: \(error)")})
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get consumer API") {
            it("works on a freshly created consumer") {
                let username = randomAlphanumericString(length: 10)
                let password = randomAlphanumericString(length: 10)
                let gender = "M"
                
                // Create a consumer
                let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
                var locator: ResourceLocator<Consumer>! = nil
                
                api.consumers.create(credentials: knurldCredentials,
                                            request: consumerCreateRequest,
                                            successHandler: { loc in locator = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator == nil {
                    fail("Unable to create consumer")
                    return
                }
                
                // Retrieve the just-created consumer
                var consumer: Consumer! = nil
                api.consumers.get(credentials: knurldCredentials,
                                         locator: locator,
                                         successHandler: { cnsmr in consumer = cnsmr },
                                         failureHandler: { error in print("ERROR: \(error)") })
                sleep(UInt32(API_CALL_TIMEOUT))
                if consumer == nil {
                    fail("Unable to retrieve consumer")
                    return
                }
                
                expect(consumer.username).to(equal(username))
            }
        }
        
        describe("the update consumer API") {
            it("doesn't fail when expected to work") {
                let username = randomAlphanumericString(length: 10)
                let password = randomAlphanumericString(length: 10)
                let gender = "M"
                
                // Create a consumer
                let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
                var locator1: ResourceLocator<Consumer>! = nil
                
                api.consumers.create(credentials: knurldCredentials,
                                            request: consumerCreateRequest,
                                            successHandler: { loc in locator1 = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator1 == nil {
                    fail("Unable to create consumer for retrieving")
                    return
                }
                
                // Update the consumer
                var locator2: ResourceLocator<Consumer>! = nil
                let updateRequest = ConsumerUpdateRequest(password: "bjkhjklsdhlkdjaskfl")
                api.consumers.update(credentials: knurldCredentials, locator: locator1, request: updateRequest,
                                            successHandler: { loc in locator2 = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator2 == nil {
                    fail("Unable to update consumer")
                    return
                }
                
                // Make sure the locator returned by update matches that returned by create
                expect(locator1).to(equal(locator2))
                
                //@todo verify consumer password update by attempting to log in
            }
        }
        
        describe("the delete consumer API") {
            it("works on a freshly created consumer") {
                let username = randomAlphanumericString(length: 10)
                let password = randomAlphanumericString(length: 10)
                let gender = "M"
                
                // Create a consumer
                let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
                var locator: ResourceLocator<Consumer>! = nil
                
                api.consumers.create(credentials: knurldCredentials,
                                            request: consumerCreateRequest,
                                            successHandler: { loc in locator = loc },
                                            failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator == nil {
                    fail("Unable to create consumer for deleting")
                    return
                }
                
                // Delete the app model
                var deleted: Bool = false
                api.consumers.delete(credentials: knurldCredentials, locator: locator,
                                            successHandler: { deleted = true },
                                            failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT)
            }
        }
    }
}



class EnrollmentSpec: QuickSpec {
    override func spec() {
        let api = KnurldV1API()
        
        var knurldCredentials: KnurldCredentials!
        api.authorize(credentials: validOAuthCredentials,
                      successHandler: { resp in
                        knurldCredentials = KnurldCredentials(developerID: TEST_DEVELOPER_ID, authorizationResponse: resp) },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        var appModelLocator: ResourceLocator<AppModel>!
        var consumerLocator: ResourceLocator<Consumer>!
        var enrollmentLocator: ResourceLocator<Enrollment>!
        beforeEach {
            // Create an app model
            let appModelRequest = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
            api.appModels.create(credentials: knurldCredentials,
                request: appModelRequest,
                successHandler: { loc in appModelLocator = loc },
                failureHandler: { error in print("ERROR: \(error)")})
            
            sleep(UInt32(API_CALL_TIMEOUT))
            if appModelLocator == nil {
                fail("Unable to create application model")
                return
            }
            
            // Create a consumer
            let username = randomAlphanumericString(length: 10)
            let password = randomAlphanumericString(length: 10)
            let gender = "M"
            let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
            
            api.consumers.create(credentials: knurldCredentials,
                request: consumerCreateRequest,
                successHandler: { loc in consumerLocator = loc },
                failureHandler: { error in print("ERROR: \(error)")})
            
            sleep(UInt32(API_CALL_TIMEOUT))
            if consumerLocator == nil {
                fail("Unable to create consumer")
                return
            }
            
            // Create the enrollment
            let request = EnrollmentCreateRequest(consumer: consumerLocator.getURL(), appModel: appModelLocator.getURL())
            
            api.enrollments.create(credentials: knurldCredentials,
                request: request,
                successHandler: { loc in enrollmentLocator = loc },
                failureHandler: { error in print("ERROR: \(error)")})
            
            sleep(UInt32(API_CALL_TIMEOUT))
            if enrollmentLocator == nil {
                fail("Unable to create enrollment")
                return
            }
        }
        
        describe("the create enrollment API") {
            it("returns a good response when called properly") {
                // Create the enrollment
                let request = EnrollmentCreateRequest(consumer: consumerLocator.getURL(), appModel: appModelLocator.getURL())
                var locator: ResourceLocator<Enrollment>? = nil
                
                api.enrollments.create(credentials: knurldCredentials,
                                       request: request,
                                       successHandler: { loc in locator = loc },
                                       failureHandler: { error in print("ERROR: \(error)")})
                
                expect(locator).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get enrollments API") {
            it("returns success when given good parameters") {
                var page: EnrollmentPage? = nil
                
                api.enrollments.getPage(credentials: knurldCredentials,
                                        successHandler: { pg in page = pg },
                                        failureHandler: { error in print("ERROR: \(error)")})
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get enrollment API") {
            it("works on a freshly created enrollment") {
                // Retrieve the just-created enrollment
                var enrollment: Enrollment! = nil
                api.enrollments.get(credentials: knurldCredentials,
                                  locator: enrollmentLocator,
                                  successHandler: { enrlmnt in enrollment = enrlmnt },
                                  failureHandler: { error in print("ERROR: \(error)") })
                sleep(UInt32(API_CALL_TIMEOUT))
                if enrollment == nil {
                    fail("Unable to retrieve enrollment")
                    return
                }
                
                expect(enrollment.consumer.href).to(equal(consumerLocator.getURL()))
            }
        }
        
        describe("the update enrollment API") {
            it("doesn't fail internally") {
                // Update the enrollment
                var locator: ResourceLocator<Enrollment>! = nil
                let request = EnrollmentUpdateRequest(enrollmentWav: "bjkhjklsdhlkdjaskfl", intervals: [EnrollmentInterval(phrase: "beep", start: 1, stop: 5)])
                api.enrollments.update(credentials: knurldCredentials, locator: enrollmentLocator, request: request,
                                       successHandler: { loc in locator = loc },
                                       failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator == nil {
                    fail("Unable to update enrollment")
                    return
                }
                
                // Make sure the locator returned by update matches that returned by create
                expect(locator).to(equal(enrollmentLocator))
                
                //@todo verify consumer password update by attempting to log in
            }
        }
        
        describe("the delete enrollment API") {
            it("works on a freshly created enrollment") {
                // Delete the enrollment
                var deleted: Bool = false
                api.enrollments.delete(credentials: knurldCredentials, locator: enrollmentLocator,
                                       successHandler: { deleted = true },
                                       failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT)
            }
        }
    }
}


class VerificationSpec: QuickSpec {
    override func spec() {
        let api = KnurldV1API()
        
        var knurldCredentials: KnurldCredentials!
        api.authorize(credentials: validOAuthCredentials,
                      successHandler: { resp in
                        knurldCredentials = KnurldCredentials(developerID: TEST_DEVELOPER_ID, authorizationResponse: resp) },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        var appModelLocator: ResourceLocator<AppModel>!
        var consumerLocator: ResourceLocator<Consumer>!
        var enrollmentLocator: ResourceLocator<Enrollment>!
        beforeEach {
            // Create an app model
            let appModelRequest = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
            api.appModels.create(credentials: knurldCredentials,
                request: appModelRequest,
                successHandler: { loc in appModelLocator = loc },
                failureHandler: { error in print("ERROR: \(error)")})
            
            sleep(UInt32(API_CALL_TIMEOUT))
            if appModelLocator == nil {
                fail("Unable to create application model")
                return
            }
            
            // Create a consumer
            let username = randomAlphanumericString(length: 10)
            let password = randomAlphanumericString(length: 10)
            let gender = "M"
            let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
            
            api.consumers.create(credentials: knurldCredentials,
                request: consumerCreateRequest,
                successHandler: { loc in consumerLocator = loc },
                failureHandler: { error in print("ERROR: \(error)")})
            
            sleep(UInt32(API_CALL_TIMEOUT))
            if consumerLocator == nil {
                fail("Unable to create consumer")
                return
            }
            
            // Create an enrollment
            let request = EnrollmentCreateRequest(consumer: consumerLocator.getURL(), appModel: appModelLocator.getURL())
            
            api.enrollments.create(credentials: knurldCredentials,
                request: request,
                successHandler: { loc in enrollmentLocator = loc },
                failureHandler: { error in print("ERROR: \(error)")})
            
            sleep(UInt32(API_CALL_TIMEOUT))
            if enrollmentLocator == nil {
                fail("Unable to create enrollment")
                return
            }
        }
        
        describe("the create verification API") {
            it("returns a good response when called properly") {
                // Create the verification
                let request = VerificationCreateRequest(consumer: consumerLocator.getURL(), appModel: appModelLocator.getURL())
                var locator: ResourceLocator<Verification>? = nil
                
                api.verifications.create(credentials: knurldCredentials,
                                         request: request,
                                         successHandler: { loc in locator = loc },
                                         failureHandler: { error in print("ERROR: \(error)")})
                
                expect(locator).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get verifications API") {
            it("returns success when given good parameters") {
                var page: VerificationPage? = nil
                
                api.verifications.getPage(credentials: knurldCredentials,
                                          successHandler: { pg in page = pg },
                                          failureHandler: { error in print("ERROR: \(error)")})
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get verification API") {
            it("works on a freshly created verification") {
                // Create a verification
                let request = VerificationCreateRequest(consumer: consumerLocator.getURL(), appModel: appModelLocator.getURL())
                var locator: ResourceLocator<Verification>!
                
                api.verifications.create(credentials: knurldCredentials,
                                         request: request,
                                         successHandler: { loc in locator = loc },
                                         failureHandler: { error in print("ERROR: \(error)")})
                
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator == nil {
                    fail("Unable to create verification")
                    return
                }
                
                // Retrieve the just-created verification
                var verification: Verification! = nil
                api.verifications.get(credentials: knurldCredentials,
                                      locator: locator,
                                      successHandler: { vrfctn in verification = vrfctn },
                                      failureHandler: { error in print("ERROR: \(error)") })
                sleep(UInt32(API_CALL_TIMEOUT))
                if verification == nil {
                    fail("Unable to retrieve verification")
                    return
                }
                
                expect(verification.consumer.href).to(equal(consumerLocator.getURL()))
            }
        }
        
        describe("the update verification API") {
            it("doesn't fail internally") {
                // Create a verification
                let request1 = VerificationCreateRequest(consumer: consumerLocator.getURL(), appModel: appModelLocator.getURL())
                var locator1: ResourceLocator<Verification>! = nil
                
                api.verifications.create(credentials: knurldCredentials,
                                         request: request1,
                                         successHandler: { loc in locator1 = loc },
                                         failureHandler: { error in print("ERROR: \(error)")})
                
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator1 == nil {
                    fail("Unable to create verification")
                    return
                }
                
                // Update the verification
                var locator2: ResourceLocator<Verification>! = nil
                let request2 = VerificationUpdateRequest(verificationWav: "bjkhjklsdhlkdjaskfl", intervals: [VerificationInterval(phrase: "beep", start: 1, stop: 5)])
                api.verifications.update(credentials: knurldCredentials, locator: locator1, request: request2,
                                         successHandler: { loc in locator2 = loc },
                                         failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator2 == nil {
                    fail("Unable to update verification")
                    return
                }
                
                // Make sure the locator returned by update matches that returned by create
                expect(locator1.getURL()).to(equal(locator2.getURL()))
            }
        }
        
        describe("the delete verification API") {
            it("works on a freshly created verification") {
                // Create a verification
                let request = VerificationCreateRequest(consumer: consumerLocator.getURL(), appModel: appModelLocator.getURL())
                var locator: ResourceLocator<Verification>! = nil
                
                api.verifications.create(credentials: knurldCredentials,
                                         request: request,
                                         successHandler: { loc in locator = loc },
                                         failureHandler: { error in print("ERROR: \(error)")})
                
                sleep(UInt32(API_CALL_TIMEOUT))
                if locator == nil {
                    fail("Unable to create verification")
                    return
                }
                
                // Delete the verification
                var deleted: Bool = false
                api.verifications.delete(credentials: knurldCredentials, locator: locator,
                                         successHandler: { deleted = true },
                                         failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT)
            }
        }
    }
}