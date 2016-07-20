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


let API_CALL_TIMEOUT = 5 // seconds
let API_CALL_TIMEOUT_NSTIMEINTERVAL = NSTimeInterval(API_CALL_TIMEOUT)
let NANOS_PER_SECOND: Int64 = 1000000000

let validOAuthCredentials = OAuthCredentials(clientID: TEST_CLIENT_ID, clientSecret: TEST_CLIENT_SECRET)

extension AppModel: Equatable {}
public func ==(lhs: AppModel, rhs: AppModel) -> Bool {
    if lhs.enrollmentRepeats == rhs.enrollmentRepeats &&
        lhs.vocabulary == rhs.vocabulary &&
        lhs.verificationLength == rhs.verificationLength
    {
        return true
    }
    
    return false
}

extension AppModelEndpoint: Equatable {}
public func ==(lhs: AppModelEndpoint, rhs: AppModelEndpoint) -> Bool {
    return lhs.url == rhs.url
}

extension ConsumerEndpoint: Equatable {}
public func ==(lhs: ConsumerEndpoint, rhs: ConsumerEndpoint) -> Bool {
    return lhs.url == rhs.url
}

extension EnrollmentEndpoint: Equatable {}
public func ==(lhs: EnrollmentEndpoint, rhs: EnrollmentEndpoint) -> Bool {
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


func makeCredentials(api api: KnurldAPI) -> KnurldCredentials! {
    return requestSync(method: api.authorization.authorize, credentials: validOAuthCredentials, arg1: TEST_DEVELOPER_ID)
}

func requestSync<CredentialsType, Arg1Type, ResponseType>
    (method method: (credentials: CredentialsType,
                     arg1: Arg1Type,
                     successHandler: (ResponseType) -> Void,
                     failureHandler: (HTTPRequestError) -> Void)
                -> Void,
            credentials: CredentialsType,
            arg1: Arg1Type)
    -> ResponseType?
{
    var response: ResponseType?
    
    let semaphore = dispatch_semaphore_create(0)
    method(credentials: credentials,
           arg1: arg1,
           successHandler: { rsp in response = rsp; dispatch_semaphore_signal(semaphore) },
           failureHandler: { error in print("ERROR: \(error)") })

    let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(API_CALL_TIMEOUT) * NANOS_PER_SECOND)
    dispatch_semaphore_wait(semaphore, timeout)
    
    return response
}

func requestSync<CredentialsType, Arg1Type, Arg2Type, ResponseType>
    (method method: (credentials: CredentialsType,
                     arg1: Arg1Type,
                     arg2: Arg2Type,
                     successHandler: (ResponseType) -> Void,
                     failureHandler: (HTTPRequestError) -> Void)
                -> Void,
            credentials: CredentialsType,
            arg1: Arg1Type,
            arg2: Arg2Type)
    -> ResponseType?
{
    var response: ResponseType?
    
    let semaphore = dispatch_semaphore_create(0)
    method(credentials: credentials,
           arg1: arg1,
           arg2: arg2,
           successHandler: { rsp in response = rsp; dispatch_semaphore_signal(semaphore) },
           failureHandler: { error in print("ERROR: \(error)") })
    
    let timeout = dispatch_time(DISPATCH_TIME_NOW, Int64(API_CALL_TIMEOUT) * NANOS_PER_SECOND)
    dispatch_semaphore_wait(semaphore, timeout)
    
    return response
}
