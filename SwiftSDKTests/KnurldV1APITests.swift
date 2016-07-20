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


let ENDPOINT_ANALYSIS_DELAY: NSTimeInterval = 3 // seconds

let SAMPLE_AUDIO_URL = "https://www.dropbox.com/s/o5sbxrxday9pyjg/bostonivorychicago.wav?dl=1"
let SAMPLE_AUDIO_NUM_WORDS = 3

let TEST_FILE_PATH = "/Users/rconway/Downloads/Canada_Pyramid_Dallas.wav"
let TEST_FILE_NUM_WORDS = 3

class AuthorizationSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        let invalidCredentials = OAuthCredentials(clientID: "asdf", clientSecret: "asdf")
        
        it("returns a response when given valid credentials") {
            let knurldCredentials = makeCredentials(api: api)
            expect(knurldCredentials).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
        }
        
        it("fails when given bad credentials") {
            var apiError: HTTPRequestError? = nil
            
            api.authorization.authorize(credentials: invalidCredentials,
                          developerID: "askdjhsakdhsak",
                          successHandler: { _ in () },
                          failureHandler: { error in apiError = error })
            
            expect(apiError).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
        }
    }
}

class StatusSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        let knurldCredentials = makeCredentials(api: api)
        
        describe("the get status API") {
            it("returns a response when called properly") {
                var status: ServiceStatus? = nil
                
                api.status.get(credentials: knurldCredentials,
                              successHandler: { stat in status = stat },
                              failureHandler: { error in print("ERROR: \(error)") })
                
                expect(status).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
    }
}


class AppModelsSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        let knurldCredentials = makeCredentials(api: api)
        
        describe("the create app model API") {
            it("returns a good response when called properly") {
                let request = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                var endpoint: AppModelEndpoint?
                
                api.appModels.create(credentials: knurldCredentials,
                                   request: request,
                                            successHandler: { ep in endpoint = ep },
                                            failureHandler: { error in print("ERROR: \(error)")})
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
        
        describe("the get app models API") {
            it("returns success when given good parameters") {
                var page: AppModelPage? = nil
                
                api.appModels.getPage(credentials: knurldCredentials,
                                      successHandler: { pg in page = pg },
                                      failureHandler: { error in print("ERROR: \(error)")})
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
        
        describe("the get app model API") {
            it("works on a freshly created app model") {
                let request = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
                guard let endpoint = requestSync(method: api.appModels.create, credentials: knurldCredentials, arg1: request) else {
                    fail("Making app model failed")
                    return
                }
                
                guard let model = requestSync(method: api.appModels.get, credentials: knurldCredentials, arg1: endpoint) else {
                    fail("Getting app model failed")
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
                guard let endpoint1 = requestSync(method: api.appModels.create, credentials: knurldCredentials, arg1: request1) else {
                    fail("Unable to create app model")
                    return
                }
                
                // Update the app model
                let request2 = AppModelUpdateRequest(enrollmentRepeats: targetEnrollmentRepeats, threshold: nil, verificationLength: nil)
                guard let endpoint2 = requestSync(method: api.appModels.update, credentials: knurldCredentials, arg1: endpoint1, arg2: request2) else {
                    fail("Unable to update app model")
                    return
                }
                
                // Make sure the endpoint returned by update matches that returned by create
                expect(endpoint1).to(equal(endpoint2))
                
                // Retrieve the (hopefully updated) app model
                guard let modelRetrieved = requestSync(method: api.appModels.get, credentials: knurldCredentials, arg1: endpoint1) else {
                    fail("Unable to get updated app model")
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
                guard let endpoint = requestSync(method: api.appModels.create, credentials: knurldCredentials, arg1: request) else {
                    fail("Unable to create app model")
                    return
                }
                
                // Delete the app model
                var deleted: Bool = false
                api.appModels.delete(credentials: knurldCredentials,
                                   endpoint: endpoint,
                                   successHandler: { deleted = true },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }

    }
}

class ConsumersSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        let knurldCredentials = makeCredentials(api: api)
        
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
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
        
        describe("the get consumers API") {
            it("returns success when given good parameters") {
                var page: ConsumerPage? = nil
                
                api.consumers.getPage(credentials: knurldCredentials,
                                    successHandler: { pg in page = pg },
                                    failureHandler: { error in print("ERROR: \(error)")})
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
        
        describe("the get consumer API") {
            it("works on a freshly created consumer") {
                let username = randomAlphanumericString(length: 10)
                let password = randomAlphanumericString(length: 10)
                let gender = "M"
                
                // Create a consumer
                let request = ConsumerCreateRequest(username: username, password: password, gender: gender)
                guard let endpoint = requestSync(method: api.consumers.create, credentials: knurldCredentials, arg1: request) else {
                    fail("Unable to create consumer")
                    return
                }
                
                // Get the just-created consumer
                guard let consumer = requestSync(method: api.consumers.get, credentials: knurldCredentials, arg1: endpoint) else {
                    fail("Unable to get consumer")
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
                guard let endpoint1 = requestSync(method: api.consumers.create, credentials: knurldCredentials, arg1: request1) else {
                    fail("Unable to create consumer")
                    return
                }
                
                // Update the consumer
                let request2 = ConsumerUpdateRequest(password: "bjkhjklsdhlkdjaskfl")
                guard let endpoint2 = requestSync(method: api.consumers.update, credentials: knurldCredentials, arg1: endpoint1, arg2: request2) else {
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
                guard let endpoint = requestSync(method: api.consumers.create, credentials: knurldCredentials, arg1: request) else {
                    fail("Unable to create consumer")
                    return
                }
                
                // Delete the app model
                var deleted: Bool = false
                api.consumers.delete(credentials: knurldCredentials,
                                   endpoint: endpoint,
                                   successHandler: { deleted = true },
                                   failureHandler: { error in print("ERROR: \(error)")})
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
    }
}



class EnrollmentSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        let knurldCredentials = makeCredentials(api: api)
        
        var appModelEndpoint: AppModelEndpoint!
        var consumerEndpoint: ConsumerEndpoint!
        var enrollmentEndpoint: EnrollmentEndpoint!
        
        beforeEach {
            // Create an app model
            let appModelRequest = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
            appModelEndpoint = requestSync(method: api.appModels.create, credentials: knurldCredentials, arg1: appModelRequest)
            if appModelEndpoint == nil { return }
            
            // Create a consumer
            let username = randomAlphanumericString(length: 10)
            let password = randomAlphanumericString(length: 10)
            let gender = "M"
            let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
            consumerEndpoint = requestSync(method: api.consumers.create, credentials: knurldCredentials, arg1: consumerCreateRequest)
            if consumerEndpoint == nil { return }
            
            // Create an enrollment
            let enrollmentRequest = EnrollmentCreateRequest(consumer: consumerEndpoint.url, appModel: appModelEndpoint.url)
            enrollmentEndpoint = requestSync(method: api.enrollments.create, credentials: knurldCredentials, arg1: enrollmentRequest)
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
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
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
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
        
        describe("the get enrollment API") {
            it("works on a freshly created enrollment") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Retrieve the just-created enrollment
                guard let enrollment = requestSync(method: api.enrollments.get, credentials: knurldCredentials, arg1: enrollmentEndpoint) else {
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
                let request = EnrollmentUpdateRequest(enrollmentWav: "bjkhjklsdhlkdjaskfl", intervals: [EnrollmentInterval(phrase: "beep", start: 1, stop: 5)])
                guard let endpoint = requestSync(method: api.enrollments.update, credentials: knurldCredentials, arg1: enrollmentEndpoint, arg2: request) else {
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
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
    }
}


class VerificationSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        let knurldCredentials = makeCredentials(api: api)
        
        var appModelEndpoint: AppModelEndpoint!
        var consumerEndpoint: ConsumerEndpoint!
        var enrollmentEndpoint: EnrollmentEndpoint!
        var verificationEndpoint: VerificationEndpoint!
        
        beforeEach {
            // Create an app model
            let appModelRequest = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: ["Toronto", "Paris", "Berlin"], verificationLength: 3)
            appModelEndpoint = requestSync(method: api.appModels.create, credentials: knurldCredentials, arg1: appModelRequest)
            if appModelEndpoint == nil { return }
            
            // Create a consumer
            let username = randomAlphanumericString(length: 10)
            let password = randomAlphanumericString(length: 10)
            let gender = "M"
            let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
            consumerEndpoint = requestSync(method: api.consumers.create, credentials: knurldCredentials, arg1: consumerCreateRequest)
            if consumerEndpoint == nil { return }
            
            // Create an enrollment
            let enrollmentRequest = EnrollmentCreateRequest(consumer: consumerEndpoint.url, appModel: appModelEndpoint.url)
            enrollmentEndpoint = requestSync(method: api.enrollments.create, credentials: knurldCredentials, arg1: enrollmentRequest)
            if enrollmentEndpoint == nil { return }
            
            // Create a verification
            let verificationRequest = VerificationCreateRequest(consumer: consumerEndpoint.url, appModel: appModelEndpoint.url)
            verificationEndpoint = requestSync(method: api.verifications.create, credentials: knurldCredentials, arg1: verificationRequest)
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
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
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
                
                expect(page).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
        
        describe("the get verification API") {
            it("works on a freshly created verification") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil || verificationEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                // Get the just-created verification
                guard let verification = requestSync(method: api.verifications.get, credentials: knurldCredentials, arg1: verificationEndpoint) else {
                    fail("Unable to get verification")
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
                guard let endpoint = requestSync(method: api.verifications.update, credentials: knurldCredentials, arg1: verificationEndpoint, arg2: request) else {
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
                
                expect(deleted).toEventually(beTrue(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
    }
}

class EndpointAnalysisSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        let knurldCredentials = makeCredentials(api: api)
        
        describe("the endpoint URL endpoint") {
            it("returns a good response when called properly") {
                let request = URLEndpointAnalysisCreateRequest(audioURL: SAMPLE_AUDIO_URL, numWords: SAMPLE_AUDIO_NUM_WORDS)
                var endpoint: EndpointAnalysisEndpoint?
                api.endpointAnalyses.endpointURL(credentials: knurldCredentials,
                                request: request,
                                successHandler: { ep in endpoint = ep },
                                failureHandler: { error in print("ERROR: \(error)") })
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
        
        describe("the endpoint file endpoint") {
            it("returns a good response when called properly") {
                // load the data
                guard let rawData = NSData(contentsOfFile: TEST_FILE_PATH) else {
                    print("Unable to load test file")
                    exit(1)
                }
                
                let request = FileEndpointAnalysisCreateRequest(audioFile: rawData, numWords: TEST_FILE_NUM_WORDS)
                var endpoint: EndpointAnalysisEndpoint?
                api.endpointAnalyses.endpointFile(credentials: knurldCredentials,
                                                 request: request,
                                                 successHandler: { ep in endpoint = ep },
                                                 failureHandler: { error in print("ERROR: \(error)") })
                
                expect(endpoint).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
        
        describe("the endpoint analysis endpoint") {
            it("returns intervals when given a good audio file") {
                let request = URLEndpointAnalysisCreateRequest(audioURL: SAMPLE_AUDIO_URL, numWords: SAMPLE_AUDIO_NUM_WORDS)
                guard let endpoint = requestSync(method: api.endpointAnalyses.endpointURL, credentials: knurldCredentials, arg1: request) else {
                    fail("Unable to start endpoint analysis")
                    return
                }
                
                sleep(UInt32(ENDPOINT_ANALYSIS_DELAY))
                
                var analysis: EndpointAnalysis?
                api.endpointAnalyses.get(credentials: knurldCredentials,
                                         endpoint: endpoint,
                                         successHandler: { anlyss in analysis = anlyss },
                                         failureHandler: { error in print("ERROR: \(error)") })
                
                expect(analysis).toEventuallyNot(beNil(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
        
    }
}