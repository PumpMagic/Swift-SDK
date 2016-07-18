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
let ENDPOINT_ANALYSIS_DELAY: NSTimeInterval = 3 // seconds
let validOAuthCredentials = OAuthCredentials(clientID: TEST_CLIENT_ID, clientSecret: TEST_CLIENT_SECRET)

let SAMPLE_AUDIO_URL = "https://www.dropbox.com/s/o5sbxrxday9pyjg/bostonivorychicago.wav?dl=1"
let SAMPLE_AUDIO_NUM_WORDS = 3

class AuthorizationSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        let invalidCredentials = OAuthCredentials(clientID: "asdf", clientSecret: "asdf")
        
        it("returns a response when given valid credentials") {
            var knurldCredentials: KnurldCredentials? = nil
            
            api.authorization.authorize(credentials: validOAuthCredentials,
                          developerID: TEST_DEVELOPER_ID,
                          successHandler: { creds in knurldCredentials = creds },
                          failureHandler: { error in print("ERROR: \(error)") })
            
            expect(knurldCredentials).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
        }
        
        it("fails when given bad credentials") {
            var apiError: HTTPRequestError? = nil
            
            api.authorization.authorize(credentials: invalidCredentials,
                          developerID: "askdjhsakdhsak",
                          successHandler: { _ in () },
                          failureHandler: { error in apiError = error })
            
            expect(apiError).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
        }
    }
}

class StatusSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        
        var knurldCredentials: KnurldCredentials!
        api.authorization.authorize(credentials: validOAuthCredentials,
                      developerID: TEST_DEVELOPER_ID,
                      successHandler: { creds in
                        knurldCredentials = creds
                      },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        describe("the get status API") {
            it("returns a response when called properly") {
                var status: ServiceStatus? = nil
                
                api.status.get(credentials: knurldCredentials,
                              successHandler: { stat in status = stat },
                              failureHandler: { error in print("ERROR: \(error)") })
                
                expect(status).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
    }
}


class AppModelsSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        
        var knurldCredentials: KnurldCredentials!
        api.authorization.authorize(credentials: validOAuthCredentials,
                      developerID: TEST_DEVELOPER_ID,
                      successHandler: { creds in
                        knurldCredentials = creds
            },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        describe("the create app model API") {
            it("returns a good response when called properly") {
                let request = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                var endpoint: AppModelEndpoint?
                
                api.appModels.create(credentials: knurldCredentials,
                                   request: request,
                                            successHandler: { ep in endpoint = ep },
                                            failureHandler: { error in print("ERROR: \(error)")})
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
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
                let request = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                let endpoint = appModelCreateSync(api, credentials: knurldCredentials, request: request)
                if endpoint == nil { return }
                
                var model: AppModel! = nil
                api.appModels.get(credentials: knurldCredentials,
                                endpoint: endpoint,
                                successHandler: { mdl in model = mdl },
                                failureHandler: { error in print("ERROR: \(error)") })
                sleep(UInt32(API_CALL_TIMEOUT))
                if model == nil {
                    fail("Get app model failed")
                    return
                }
                
                expect(model.enrollmentRepeats).to(equal(request.enrollmentRepeats))
            }
        }
        
        describe("the update app model API") {
            it("works on a freshly created app model") {
                let initialEnrollmentRepeats = 3
                let targetEnrollmentRepeats = 5
                
                // Create an app model
                let request1 = AppModelCreateRequest(enrollmentRepeats: initialEnrollmentRepeats, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                let endpoint1 = appModelCreateSync(api, credentials: knurldCredentials, request: request1)
                if endpoint1 == nil { return }
                
                // Update the app model
                let request2 = AppModelUpdateRequest(enrollmentRepeats: targetEnrollmentRepeats, threshold: nil, verificationLength: nil)
                var endpoint2: AppModelEndpoint! = nil
                api.appModels.update(credentials: knurldCredentials,
                                   endpoint: endpoint1,
                                   request: request2,
                                   successHandler: { ep in endpoint2 = ep },
                                   failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if endpoint2 == nil {
                    fail("Unable to update app model")
                    return
                }
                
                // Make sure the endpoint returned by update matches that returned by create
                expect(endpoint1).to(equal(endpoint2))
                
                // Retrieve the (hopefully updated) app model
                var modelRetrieved: AppModel! = nil
                api.appModels.get(credentials: knurldCredentials,
                                endpoint: endpoint2,
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
                let request = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                let endpoint = appModelCreateSync(api, credentials: knurldCredentials, request: request)
                if endpoint == nil { return }
                
                // Delete the app model
                var deleted: Bool = false
                api.appModels.delete(credentials: knurldCredentials,
                                   endpoint: endpoint,
                                   successHandler: { deleted = true },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT)
            }
        }

    }
}

class ConsumersSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        
        var knurldCredentials: KnurldCredentials!
        api.authorization.authorize(credentials: validOAuthCredentials,
                      developerID: TEST_DEVELOPER_ID,
                      successHandler: { creds in
                        knurldCredentials = creds
            },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        describe("the create consumer API") {
            it("returns a good response when called properly") {
                let username = randomAlphanumericString(length: 10)
                let password = randomAlphanumericString(length: 10)
                let gender = "M"
                
                let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
                var endpoint: ConsumerEndpoint? = nil
                
                api.consumers.create(credentials: knurldCredentials,
                                   request: consumerCreateRequest,
                                   successHandler: { ep in endpoint = ep },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
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
                let request = ConsumerCreateRequest(username: username, password: password, gender: gender)
                let endpoint = consumerCreateSync(api, credentials: knurldCredentials, request: request)
                if endpoint == nil { return }
                
                // Retrieve the just-created consumer
                var consumer: Consumer! = nil
                api.consumers.get(credentials: knurldCredentials,
                                endpoint: endpoint,
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
                let request1 = ConsumerCreateRequest(username: username, password: password, gender: gender)
                let endpoint1 = consumerCreateSync(api, credentials: knurldCredentials, request: request1)
                if endpoint1 == nil { return }
                
                // Update the consumer
                let request2 = ConsumerUpdateRequest(password: "bjkhjklsdhlkdjaskfl")
                var endpoint2: ConsumerEndpoint! = nil
                api.consumers.update(credentials: knurldCredentials,
                                   endpoint: endpoint1,
                                   request: request2,
                                   successHandler: { ep in endpoint2 = ep },
                                   failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if endpoint2 == nil {
                    fail("Unable to update consumer")
                    return
                }
                
                // Make sure the endpoint returned by update matches that returned by create
                expect(endpoint1).to(equal(endpoint2))
                
                //@todo verify consumer password update by attempting to log in
            }
        }
        
        describe("the delete consumer API") {
            it("works on a freshly created consumer") {
                let username = randomAlphanumericString(length: 10)
                let password = randomAlphanumericString(length: 10)
                let gender = "M"
                
                // Create a consumer
                let request = ConsumerCreateRequest(username: username, password: password, gender: gender)
                let endpoint = consumerCreateSync(api, credentials: knurldCredentials, request: request)
                if endpoint == nil { return }
                
                // Delete the app model
                var deleted: Bool = false
                api.consumers.delete(credentials: knurldCredentials,
                                   endpoint: endpoint,
                                   successHandler: { deleted = true },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT)
            }
        }
    }
}



class EnrollmentSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        
        var knurldCredentials: KnurldCredentials!
        api.authorization.authorize(credentials: validOAuthCredentials,
                      developerID: TEST_DEVELOPER_ID,
                      successHandler: { creds in
                        knurldCredentials = creds
            },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        
        var appModelEndpoint: AppModelEndpoint!
        var consumerEndpoint: ConsumerEndpoint!
        var enrollmentEndpoint: EnrollmentEndpoint!
        
        beforeEach {
            // Create an app model
            let appModelRequest = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
            appModelEndpoint = appModelCreateSync(api, credentials: knurldCredentials, request: appModelRequest)
            if appModelEndpoint == nil { return }
            
            // Create a consumer
            let username = randomAlphanumericString(length: 10)
            let password = randomAlphanumericString(length: 10)
            let gender = "M"
            let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
            consumerEndpoint = consumerCreateSync(api, credentials: knurldCredentials, request: consumerCreateRequest)
            if consumerEndpoint == nil { return }
            
            // Create an enrollment
            let enrollmentRequest = EnrollmentCreateRequest(consumer: consumerEndpoint.url, appModel: appModelEndpoint.url)
            enrollmentEndpoint = enrollmentCreateSync(api, credentials: knurldCredentials, request: enrollmentRequest)
            if enrollmentEndpoint == nil { return }
        }
        
        describe("the create enrollment API") {
            it("returns a good response when called properly") {
                if appModelEndpoint == nil || consumerEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Create the enrollment
                let request = EnrollmentCreateRequest(consumer: consumerEndpoint.url, appModel: appModelEndpoint.url)
                var endpoint: EnrollmentEndpoint? = nil
                
                api.enrollments.create(credentials: knurldCredentials,
                                       request: request,
                                       successHandler: { ep in endpoint = ep },
                                       failureHandler: { error in print("ERROR: \(error)")})
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get enrollments API") {
            it("returns success when given good parameters") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                var page: EnrollmentPage? = nil
                
                api.enrollments.getPage(credentials: knurldCredentials,
                                        successHandler: { pg in page = pg },
                                        failureHandler: { error in print("ERROR: \(error)")})
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get enrollment API") {
            it("works on a freshly created enrollment") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Retrieve the just-created enrollment
                var enrollment: Enrollment! = nil
                api.enrollments.get(credentials: knurldCredentials,
                                  endpoint: enrollmentEndpoint,
                                  successHandler: { enrlmnt in enrollment = enrlmnt },
                                  failureHandler: { error in print("ERROR: \(error)") })
                sleep(UInt32(API_CALL_TIMEOUT))
                if enrollment == nil {
                    fail("Unable to retrieve enrollment")
                    return
                }
                
                expect(enrollment.consumer.href).to(equal(consumerEndpoint.url))
            }
        }
        
        describe("the update enrollment API") {
            it("doesn't fail internally") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Update the enrollment
                var endpoint: EnrollmentEndpoint! = nil
                let request = EnrollmentUpdateRequest(enrollmentWav: "bjkhjklsdhlkdjaskfl", intervals: [EnrollmentInterval(phrase: "beep", start: 1, stop: 5)])
                api.enrollments.update(credentials: knurldCredentials,
                                     endpoint: enrollmentEndpoint,
                                     request: request,
                                     successHandler: { ep in endpoint = ep },
                                     failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if endpoint == nil {
                    fail("Unable to update enrollment")
                    return
                }
                
                // Make sure the endpoint returned by update matches that returned by create
                expect(endpoint).to(equal(enrollmentEndpoint))
                
                //@todo verify consumer password update by attempting to log in
            }
        }
        
        describe("the delete enrollment API") {
            it("works on a freshly created enrollment") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Delete the enrollment
                var deleted: Bool = false
                api.enrollments.delete(credentials: knurldCredentials,
                                     endpoint: enrollmentEndpoint,
                                     successHandler: { deleted = true },
                                     failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT)
            }
        }
    }
}


class VerificationSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        
        var knurldCredentials: KnurldCredentials!
        api.authorization.authorize(credentials: validOAuthCredentials,
                      developerID: TEST_DEVELOPER_ID,
                      successHandler: { creds in
                        knurldCredentials = creds
            },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        var appModelEndpoint: AppModelEndpoint!
        var consumerEndpoint: ConsumerEndpoint!
        var enrollmentEndpoint: EnrollmentEndpoint!
        var verificationEndpoint: VerificationEndpoint!
        
        beforeEach {
            // Create an app model
            let appModelRequest = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
            appModelEndpoint = appModelCreateSync(api, credentials: knurldCredentials, request: appModelRequest)
            if appModelEndpoint == nil { return }
            
            // Create a consumer
            let username = randomAlphanumericString(length: 10)
            let password = randomAlphanumericString(length: 10)
            let gender = "M"
            let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
            consumerEndpoint = consumerCreateSync(api, credentials: knurldCredentials, request: consumerCreateRequest)
            if consumerEndpoint == nil { return }
            
            // Create an enrollment
            let enrollmentRequest = EnrollmentCreateRequest(consumer: consumerEndpoint.url, appModel: appModelEndpoint.url)
            enrollmentEndpoint = enrollmentCreateSync(api, credentials: knurldCredentials, request: enrollmentRequest)
            if enrollmentEndpoint == nil { return }
            
            // Create a verification
            let verificationRequest = VerificationCreateRequest(consumer: consumerEndpoint.url, appModel: appModelEndpoint.url)
            verificationEndpoint = verificationCreateSync(api, credentials: knurldCredentials, request: verificationRequest)
            if verificationEndpoint == nil { return }
        }
        
        describe("the create verification API") {
            it("returns a good response when called properly") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Create the verification
                let request = VerificationCreateRequest(consumer: consumerEndpoint.url, appModel: appModelEndpoint.url)
                var endpoint: VerificationEndpoint? = nil
                
                api.verifications.create(credentials: knurldCredentials,
                                       request: request,
                                       successHandler: { ep in endpoint = ep },
                                       failureHandler: { error in print("ERROR: \(error)")})
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get verifications API") {
            it("returns success when given good parameters") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil || verificationEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                var page: VerificationPage? = nil
                
                api.verifications.getPage(credentials: knurldCredentials,
                                        successHandler: { pg in page = pg },
                                        failureHandler: { error in print("ERROR: \(error)")})
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the get verification API") {
            it("works on a freshly created verification") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil || verificationEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Retrieve the just-created verification
                var verification: Verification! = nil
                api.verifications.get(credentials: knurldCredentials,
                                      endpoint: verificationEndpoint,
                                      successHandler: { vrfctn in verification = vrfctn },
                                      failureHandler: { error in print("ERROR: \(error)") })
                sleep(UInt32(API_CALL_TIMEOUT))
                if verification == nil {
                    fail("Unable to retrieve verification")
                    return
                }
            
                expect(verification.consumer.href).to(equal(consumerEndpoint.url))
            }
        }
        
        describe("the update verification API") {
            it("doesn't fail internally") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil || verificationEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Update the verification
                let request = VerificationUpdateRequest(verificationWav: "bjkhjklsdhlkdjaskfl", intervals: [VerificationInterval(phrase: "beep", start: 1, stop: 5)])
                var endpoint: VerificationEndpoint! = nil
                api.verifications.update(credentials: knurldCredentials,
                                       endpoint: verificationEndpoint,
                                       request: request,
                                       successHandler: { ep in endpoint = ep },
                                       failureHandler: { error in print("ERROR: \(error)")})
                sleep(UInt32(API_CALL_TIMEOUT))
                if endpoint == nil {
                    fail("Unable to update verification")
                    return
                }
                
                // Make sure the endpoint returned by update matches that returned by create
                expect(endpoint.url).to(equal(verificationEndpoint.url))
            }
        }
        
        describe("the delete verification API") {
            it("works on a freshly created verification") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil || verificationEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Delete the verification
                var deleted: Bool = false
                api.verifications.delete(credentials: knurldCredentials,
                                       endpoint: verificationEndpoint,
                                       successHandler: { deleted = true },
                                       failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT)
            }
        }
    }
}

class EndpointAnalysisSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        
        var knurldCredentials: KnurldCredentials!
        api.authorization.authorize(credentials: validOAuthCredentials,
                      developerID: TEST_DEVELOPER_ID,
                      successHandler: { creds in
                        knurldCredentials = creds
            },
                      failureHandler: { error in print("ERROR: \(error)") })
        sleep(UInt32(API_CALL_TIMEOUT))
        
        describe("the endpoint URL endpoint") {
            it("returns a good response when called properly") {
                let request = URLEndpointAnalysisCreateRequest(audioURL: SAMPLE_AUDIO_URL, numWords: SAMPLE_AUDIO_NUM_WORDS)
                var endpoint: EndpointAnalysisEndpoint?
                api.endpointAnalyses.endpointURL(credentials: knurldCredentials,
                                request: request,
                                successHandler: { ep in endpoint = ep },
                                failureHandler: { error in print("ERROR: \(error)") })
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
        describe("the endpoint analysis endpoint") {
            it("returns intervals when given a good audio file") {
                let request = URLEndpointAnalysisCreateRequest(audioURL: SAMPLE_AUDIO_URL, numWords: SAMPLE_AUDIO_NUM_WORDS)
                let endpoint = endpointURLSync(api, credentials: knurldCredentials, request: request)
                if endpoint == nil { return }
                
                sleep(UInt32(ENDPOINT_ANALYSIS_DELAY))
                
                var analysis: EndpointAnalysis?
                api.endpointAnalyses.get(credentials: knurldCredentials,
                                         endpoint: endpoint,
                                         successHandler: { anlyss in analysis = anlyss },
                                         failureHandler: { error in print("ERROR: \(error)") })
                
                expect(analysis).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT)
            }
        }
        
    }
}