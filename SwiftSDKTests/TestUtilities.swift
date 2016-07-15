//
//  TestUtilities.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/15/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Quick
import Nimble
@testable import SwiftSDK


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

extension AppModelEndpoint: Equatable {}
func ==(lhs: AppModelEndpoint, rhs: AppModelEndpoint) -> Bool {
    return lhs.url == rhs.url
}

extension ConsumerEndpoint: Equatable {}
func ==(lhs: ConsumerEndpoint, rhs: ConsumerEndpoint) -> Bool {
    return lhs.url == rhs.url
}

extension EnrollmentEndpoint: Equatable {}
func ==(lhs: EnrollmentEndpoint, rhs: EnrollmentEndpoint) -> Bool {
    return lhs.url == rhs.url
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


func appModelCreateSync(api: KnurldV1API, credentials: KnurldCredentials, request: AppModelCreateRequest) -> AppModelEndpoint! {
    var endpoint: AppModelEndpoint!
    
    api.createAppModel(credentials: credentials,
                       request: request,
                       successHandler: { ep in endpoint = ep },
                       failureHandler: { error in print("ERROR: \(error)")})
    sleep(UInt32(API_CALL_TIMEOUT))
    
    if endpoint == nil {
        fail("Unable to create app model")
    }
    
    return endpoint
}

func consumerCreateSync(api: KnurldV1API, credentials: KnurldCredentials, request: ConsumerCreateRequest) -> ConsumerEndpoint! {
    var endpoint: ConsumerEndpoint!
    
    api.createConsumer(credentials: credentials,
                       request: request,
                       successHandler: { ep in endpoint = ep },
                       failureHandler: { error in print("ERROR: \(error)")})
    sleep(UInt32(API_CALL_TIMEOUT))
    
    if endpoint == nil {
        fail("Unable to create consumer")
    }
    
    return endpoint
}

func enrollmentCreateSync(api: KnurldV1API, credentials: KnurldCredentials, request: EnrollmentCreateRequest) -> EnrollmentEndpoint! {
    var endpoint: EnrollmentEndpoint!
    
    api.createEnrollment(credentials: credentials,
                         request: request,
                         successHandler: { ep in endpoint = ep },
                         failureHandler: { error in print("ERROR: \(error)")})
    sleep(UInt32(API_CALL_TIMEOUT))
    
    if endpoint == nil {
        fail("Unable to create consumer")
    }
    
    return endpoint
}

func verificationCreateSync(api: KnurldV1API, credentials: KnurldCredentials, request: VerificationCreateRequest) -> VerificationEndpoint! {
    var endpoint: VerificationEndpoint!
    
    api.createVerification(credentials: credentials,
                           request: request,
                           successHandler: { ep in endpoint = ep },
                           failureHandler: { error in print("ERROR: \(error)")})
    sleep(UInt32(API_CALL_TIMEOUT))
    
    if endpoint == nil {
        fail("Unable to create consumer")
    }
    
    return endpoint
}

func endpointURLSync(api: KnurldV1API, credentials: KnurldCredentials, request: URLEndpointAnalysisCreateRequest) -> EndpointAnalysisEndpoint! {
    var endpoint: EndpointAnalysisEndpoint!
    api.endpointURL(credentials: credentials,
                    request: request,
                    successHandler: { ep in endpoint = ep },
                    failureHandler: { error in print("ERROR: \(error)") })
    sleep(UInt32(API_CALL_TIMEOUT))
    
    if endpoint == nil {
        fail("Unable to create consumer")
    }
    
    return endpoint
}

