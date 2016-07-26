//
//  KnurldSDKTests.swift
//  KnurldSDKTests
//
//  Created by Ryan Conway on 7/7/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Quick
import Nimble
@testable import KnurldSDK


let ENDPOINT_ANALYSIS_DELAY: NSTimeInterval = 5 // seconds
let ENROLLMENT_DELAY: UInt32 = 5 // seconds
let VERIFICATION_DELAY: UInt32 = 5 // seconds

let SAMPLE_AUDIO_URL = "https://www.dropbox.com/s/o5sbxrxday9pyjg/bostonivorychicago.wav?dl=1"
let SAMPLE_AUDIO_NUM_WORDS = 3

let TEST_FILE_PATH = "/Users/rconway/Downloads/Canada_Pyramid_Dallas.wav"
let TEST_FILE_NUM_WORDS = 3

let VOCABULARY = ["Pyramid", "Dallas", "Canada"]
let ENROLLMENT_WAV_URL = "https://www.dropbox.com/s/tx24ztz7vjgax4v/dcp?dl=1";
let ENROLLMENT_INTERVALS = [EnrollmentInterval(phrase: "Dallas", start: 562, stop: 1292),
                            EnrollmentInterval(phrase: "Dallas", start: 1953, stop: 2643),
                            EnrollmentInterval(phrase: "Dallas", start: 3483, stop: 4153),
                            EnrollmentInterval(phrase: "Canada", start: 5003, stop: 5713),
                            EnrollmentInterval(phrase: "Canada", start: 6493, stop: 7243),
                            EnrollmentInterval(phrase: "Canada", start: 7941, stop: 8662),
                            EnrollmentInterval(phrase: "Pyramid", start: 9433, stop: 10063),
                            EnrollmentInterval(phrase: "Pyramid", start: 10862, stop: 11483),
                            EnrollmentInterval(phrase: "Pyramid", start: 12332, stop: 12962)]

// [phrases : (url, intervals)]
// Actual values

let VERIFICATIONS = [["Canada", "Dallas", "Pyramid"]: ("https://www.dropbox.com/s/m4s52x8l4o6l2id/Canada_Dallas_Pyramid.wav?dl=1",
                                                        [VerificationInterval(phrase: "Canada", start: 532, stop: 1292),
                                                        VerificationInterval(phrase: "Dallas", start: 1713, stop: 2413),
                                                        VerificationInterval(phrase: "Pyramid", start: 3113, stop: 3753)]),
                     ["Canada", "Pyramid", "Dallas"]: ("https://www.dropbox.com/s/hytfzzv3pm0evti/Canada_Pyramid_Dallas.wav?dl=1",
                                                        [VerificationInterval(phrase: "Canada", start: 622, stop: 1423),
                                                        VerificationInterval(phrase: "Pyramid", start: 2153, stop: 2793),
                                                        VerificationInterval(phrase: "Dallas", start: 3623, stop: 4212)]),
                     ["Dallas", "Canada", "Pyramid"]: ("https://www.dropbox.com/s/n8j6bz3lpyrz5ff/Dallas_Canada_Pyramid.wav?dl=1",
                                                        [VerificationInterval(phrase: "Dallas", start: 682, stop: 1483),
                                                        VerificationInterval(phrase: "Canada", start: 2133, stop: 2923),
                                                        VerificationInterval(phrase: "Pyramid", start: 3703, stop: 4303)]),
                     ["Dallas", "Pyramid", "Canada"]: ("https://www.dropbox.com/s/iam145el09zi29s/Dallas_Pyramid_Canada.wav?dl=1",
                                                        [VerificationInterval(phrase: "Dallas", start: 522, stop: 1272),
                                                        VerificationInterval(phrase: "Pyramid", start: 1862, stop: 2493),
                                                        VerificationInterval(phrase: "Canada", start: 3153, stop: 3953)]),
                     ["Pyramid", "Canada", "Dallas"]: ("https://www.dropbox.com/s/rps6ztxfq54a9to/Pyramid_Canada_Dallas.wav?dl=1",
                                                        [VerificationInterval(phrase: "Pyramid", start: 593, stop: 1203),
                                                        VerificationInterval(phrase: "Canada", start: 1942, stop: 2713),
                                                        VerificationInterval(phrase: "Dallas", start: 3193, stop: 3793)]),
                     ["Pyramid", "Dallas", "Canada"]: ("https://www.dropbox.com/s/diqggaure66nlgz/Pyramid_Dallas_Canada.wav?dl=1",
                                                        [VerificationInterval(phrase: "Pyramid", start: 862, stop: 1473),
                                                        VerificationInterval(phrase: "Dallas", start: 2173, stop: 2793),
                                                        VerificationInterval(phrase: "Canada", start: 3473, stop: 4113)])]
 

/*
// Values with at least 601ms intervals
let VERIFICATIONS = [["Canada", "Dallas", "Pyramid"]: ("https://www.dropbox.com/s/m4s52x8l4o6l2id/Canada_Dallas_Pyramid.wav?dl=1",
    [VerificationInterval(phrase: "Canada", start: 532, stop: 1292),
        VerificationInterval(phrase: "Dallas", start: 1713, stop: 2413),
        VerificationInterval(phrase: "Pyramid", start: 3113, stop: 3753)]),
                     ["Canada", "Pyramid", "Dallas"]: ("https://www.dropbox.com/s/hytfzzv3pm0evti/Canada_Pyramid_Dallas.wav?dl=1",
                        [VerificationInterval(phrase: "Canada", start: 622, stop: 1423),
                            VerificationInterval(phrase: "Pyramid", start: 2153, stop: 2793),
                            VerificationInterval(phrase: "Dallas", start: 3623, stop: 4224)]),
                     ["Dallas", "Canada", "Pyramid"]: ("https://www.dropbox.com/s/n8j6bz3lpyrz5ff/Dallas_Canada_Pyramid.wav?dl=1",
                        [VerificationInterval(phrase: "Dallas", start: 682, stop: 1483),
                            VerificationInterval(phrase: "Canada", start: 2133, stop: 2923),
                            VerificationInterval(phrase: "Pyramid", start: 3703, stop: 4304)]),
                     ["Dallas", "Pyramid", "Canada"]: ("https://www.dropbox.com/s/iam145el09zi29s/Dallas_Pyramid_Canada.wav?dl=1",
                        [VerificationInterval(phrase: "Dallas", start: 522, stop: 1272),
                            VerificationInterval(phrase: "Pyramid", start: 1862, stop: 2493),
                            VerificationInterval(phrase: "Canada", start: 3153, stop: 3953)]),
                     ["Pyramid", "Canada", "Dallas"]: ("https://www.dropbox.com/s/rps6ztxfq54a9to/Pyramid_Canada_Dallas.wav?dl=1",
                        [VerificationInterval(phrase: "Pyramid", start: 593, stop: 1203),
                            VerificationInterval(phrase: "Canada", start: 1942, stop: 2713),
                            VerificationInterval(phrase: "Dallas", start: 3193, stop: 3794)]),
                     ["Pyramid", "Dallas", "Canada"]: ("https://www.dropbox.com/s/diqggaure66nlgz/Pyramid_Dallas_Canada.wav?dl=1",
                        [VerificationInterval(phrase: "Pyramid", start: 862, stop: 1473),
                            VerificationInterval(phrase: "Dallas", start: 2173, stop: 2794),
                            VerificationInterval(phrase: "Canada", start: 3473, stop: 4113)])]
*/

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
        guard let knurldCredentials = makeCredentials(api: api) else {
            print("Can't run status tests. Unable to get credentials!")
            return
        }
        
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
        guard let knurldCredentials = makeCredentials(api: api) else {
            print("Can't run app model tests. Unable to get credentials!")
            return
        }
        
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
        guard let knurldCredentials = makeCredentials(api: api) else {
            print("Can't run consumer tests. Unable to get credentials!")
            return
        }
        
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
        
        describe("the authenticate consumer API") {
            it("works on a freshly created consumer") {
                let username = randomAlphanumericString(length: 10)
                let password = randomAlphanumericString(length: 10)
                let gender = "M"
                
                // Create a consumer
                let request1 = ConsumerCreateRequest(username: username, password: password, gender: gender)
                guard let _ = requestSync(method: api.consumers.create, credentials: knurldCredentials, arg1: request1) else {
                    fail("Unable to create consumer")
                    return
                }
                
                // Authenticate the consumer
                let request2 = ConsumerAuthenticateRequest(username: username, password: password)
                guard let consumerCredentials = requestSync(method: api.consumers.authenticate, credentials: knurldCredentials, arg1: request2) else {
                    fail("Unable to authenticate consumer")
                    return
                }
                
                expect(consumerCredentials.authorization).to(equal(knurldCredentials.authorization))
            }
            
            it("fails when given garbage credentials") {
                let request = ConsumerAuthenticateRequest(username: "aljsdhkjqhwq", password: "alsjhdlak")
                var failed: Bool = false
                api.consumers.authenticate(credentials: knurldCredentials,
                                           request: request,
                                           successHandler: { _ in () },
                                           failureHandler: { _ in failed = true })
                
                expect(failed).toEventually(beTrue(), timeout: API_CALL_TIMEOUT_NSTIMEINTERVAL)
            }
        }
    }
}



class EnrollmentSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        guard let knurldCredentials = makeCredentials(api: api) else {
            print("Can't run enrollment tests. Unable to get credentials!")
            return
        }
        
        var appModelEndpoint: AppModelEndpoint!
        var consumerEndpoint: ConsumerEndpoint!
        var enrollmentEndpoint: EnrollmentEndpoint!
        
        beforeEach {
            // Create an app model
            let appModelRequest = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: VOCABULARY, verificationLength: 3)
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
        
        /* this is more of a server test, not a client test... skip for now
        describe("the update enrollment API") {
            it("doesn't fail internally when given bad data") {
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
            }
        }*/
        
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
        
        describe("the full enrollment flow") {
            it("works with known good data") {
                if appModelEndpoint == nil || consumerEndpoint == nil || enrollmentEndpoint == nil {
                    fail("Missing prerequisite")
                    return
                }
                
                let request = EnrollmentUpdateRequest(enrollmentWav: ENROLLMENT_WAV_URL, intervals: ENROLLMENT_INTERVALS)
                guard let endpoint = requestSync(method: api.enrollments.update, credentials: knurldCredentials, arg1: enrollmentEndpoint, arg2: request) else {
                    fail("Unable to update enrollment")
                    return
                }
                
                sleep(ENROLLMENT_DELAY)
                
                // Retrieve the just-created enrollment
                guard let enrollment = requestSync(method: api.enrollments.get, credentials: knurldCredentials, arg1: endpoint) else {
                    fail("Unable to retrieve enrollment")
                    return
                }
                
                expect(enrollment.status).to(equal("completed"))
            }
        }
    }
}


class VerificationSpec: QuickSpec {
    override func spec() {
        let api = KnurldAPI()
        guard let knurldCredentials = makeCredentials(api: api) else {
            print("Can't run verification tests. Unable to get credentials!")
            return
        }
        
        var appModelEndpoint: AppModelEndpoint!
        var consumerEndpoint: ConsumerEndpoint!
        var enrollmentEndpoint: EnrollmentEndpoint!
        var verificationEndpoint: VerificationEndpoint!
        
        beforeEach {
            // Create an app model
            let appModelRequest = AppModelCreateRequest(enrollmentRepeats: 3, vocabulary: VOCABULARY, verificationLength: 3)
            appModelEndpoint = requestSync(method: api.appModels.create, credentials: knurldCredentials, arg1: appModelRequest)
            if appModelEndpoint == nil { return }
            
            // Create a consumer
            let username = randomAlphanumericString(length: 10)
            let password = randomAlphanumericString(length: 10)
            let gender = "M"
            let consumerCreateRequest = ConsumerCreateRequest(username: username, password: password, gender: gender)
            consumerEndpoint = requestSync(method: api.consumers.create, credentials: knurldCredentials, arg1: consumerCreateRequest)
            if consumerEndpoint == nil { return }
            
            // Create and complete an enrollment
            let enrollmentRequest = EnrollmentCreateRequest(consumer: consumerEndpoint.url, appModel: appModelEndpoint.url)
            enrollmentEndpoint = requestSync(method: api.enrollments.create, credentials: knurldCredentials, arg1: enrollmentRequest)
            if enrollmentEndpoint == nil { return }
            let request = EnrollmentUpdateRequest(enrollmentWav: ENROLLMENT_WAV_URL, intervals: ENROLLMENT_INTERVALS)
            guard let endpoint = requestSync(method: api.enrollments.update, credentials: knurldCredentials, arg1: enrollmentEndpoint, arg2: request) else {
                fail("Unable to update enrollment")
                return
            }
            sleep(ENROLLMENT_DELAY)
            guard let enrollment = requestSync(method: api.enrollments.get, credentials: knurldCredentials, arg1: endpoint) else {
                fail("Unable to retrieve enrollment")
                return
            }
            if enrollment.status != "completed" { return }
            
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
        
        describe("the full verification flow") {
            it("works when given good data") {
                // Get the verification
                guard let verification1 = requestSync(method: api.verifications.get, credentials: knurldCredentials, arg1: verificationEndpoint) else {
                    fail("Unable to get verification")
                    return
                }
                
                if verification1.instructions.data == nil {
                    fail("Missing verification data")
                    return
                }
                
                let tuple = VERIFICATIONS[verification1.instructions.data!.phrases]
                if tuple == nil {
                    fail("Unexpected verification phrases")
                    return
                }
                let request = VerificationUpdateRequest(verificationWav: tuple!.0, intervals: tuple!.1)
                
                // Perform the verification
                guard let ep = requestSync(method: api.verifications.update, credentials: knurldCredentials, arg1: verificationEndpoint, arg2: request) else {
                    fail("Unable to perform verification")
                    return
                }
                
                sleep(VERIFICATION_DELAY)
                
                if ep.url != verification1.href {
                    fail("Verification endpoint mismatch")
                }
                
                // Get the verification
                guard let verification2 = requestSync(method: api.verifications.get, credentials: knurldCredentials, arg1: verificationEndpoint) else {
                    fail("Unable to get verification")
                    return
                }
                
                guard let verified = verification2.verified else {
                    fail("Verification failed")
                    return
                }
                expect(verified).to(equal(true))
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
        
        /* this is more of a server test, not a client test... skip for now
        describe("the update verification API") {
            it("doesn't fail internally when given bad data") {
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
        */
        
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
        guard let knurldCredentials = makeCredentials(api: api) else {
            print("Can't run endpoint analysis tests. Unable to get credentials!")
            return
        }
        
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
                
                guard let analysis = requestSync(method: api.endpointAnalyses.get, credentials: knurldCredentials, arg1: endpoint) else {
                    fail("Unable to get results of endpoint analysis")
                    return
                }
                
                print("Endpoint analysis results: \(analysis)")
            }
        }
        
    }
}