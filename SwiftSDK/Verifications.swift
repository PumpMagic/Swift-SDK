//
//  Verifications.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/14/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


private struct VerificationConstants {
    static let consumerParam = "consumer"
    static let appModelParam = "application"
    static let hrefParam = "href"
    
    static let verificationWavParam = "verification.wav"
    static let intervalsParam = "intervals"
    
    static let phraseParam = "phrase"
    static let startParam = "start"
    static let stopParam = "stop"
    
    static let modeParam = "mode"
    static let usernameParam = "username"
    static let createdTimeParam = "createdTime"
    static let instructionsParam = "instructions"
    static let dataParam = "data"
    static let directionsParam = "directions"
    static let optionalParam = "optional"
    static let requiresParam = "requires"
    static let stepParam = "step"
    static let statusParam = "status"
    static let verifiedParam = "verified"
    static let verifiedPhrasesParam = "verified_phrases"
    
    static let limitParam = "limit"
    static let nextParam = "next"
    static let itemsParam = "items"
    static let prevParam = "prev"
    static let totalParam = "total"
    static let offsetParam = "offset"
}

public struct VerificationCreateRequest: JSONEncodable, JSONDecodable {
    let consumer: String
    let appModel: String
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            VerificationConstants.consumerParam: .String(self.consumer),
            VerificationConstants.appModelParam: .String(self.appModel)])
    }
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.consumer = try json.string(VerificationConstants.consumerParam)
        self.appModel = try json.string(VerificationConstants.appModelParam)
    }
    
    public init(consumer: String, appModel: String) {
        self.consumer = consumer
        self.appModel = appModel
    }
}

public struct VerificationInterval: JSONEncodable, JSONDecodable {
    let phrase: String
    let start: Int
    let stop: Int
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            VerificationConstants.phraseParam: .String(self.phrase),
            VerificationConstants.startParam: .Int(self.start),
            VerificationConstants.stopParam: .Int(self.stop)])
    }
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.phrase = try json.string(VerificationConstants.phraseParam)
        self.start = try json.int(VerificationConstants.startParam)
        self.stop = try json.int(VerificationConstants.stopParam)
    }
    
    public init(phrase: String, start: Int, stop: Int) {
        self.phrase = phrase
        self.start = start
        self.stop = stop
    }
}

public struct VerificationUpdateRequest: JSONEncodable, JSONDecodable {
    let verificationWav: WebAddress
    let intervals: [VerificationInterval]
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            VerificationConstants.verificationWavParam: .String(self.verificationWav),
            VerificationConstants.intervalsParam: .Array(self.intervals.map( { interval in interval.toJSON() }))
            ])
    }
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.verificationWav = try json.string(VerificationConstants.verificationWavParam)
        self.intervals = try json.array(VerificationConstants.intervalsParam).map(VerificationInterval.init)
    }
    
    public init(verificationWav: WebAddress, intervals: [VerificationInterval]) {
        self.verificationWav = verificationWav
        self.intervals = intervals
    }
}

public struct VerificationApplication: JSONDecodable {
    public let href: String
    public let mode: String
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.href = try json.string(VerificationConstants.hrefParam)
        self.mode = try json.string(VerificationConstants.modeParam)
    }
}

public struct VerificationConsumer: JSONDecodable {
    public let href: String
    public let username: String
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.href = try json.string(VerificationConstants.hrefParam)
        self.username = try json.string(VerificationConstants.usernameParam)
    }
}

public struct VerificationData: JSONDecodable {
    public let phrase: [String]
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.phrase = try json.array(VerificationConstants.phraseParam).map(String.init)
    }
}

public struct VerificationInstructions: JSONDecodable {
    public let data: VerificationData?
    public let directions: String
    //@todo let optional: [???]?
    public let requires: [String]?
    public let step: Int
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.data = try json.decode(VerificationConstants.dataParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])
        self.directions = try json.string(VerificationConstants.directionsParam)
        self.requires = try json.array(VerificationConstants.requiresParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])?.map(String.init)
        self.step = try json.int(VerificationConstants.stepParam)
    }
}

public struct Verification: JSONDecodable {
    public let application: VerificationApplication
    public let consumer: VerificationConsumer
    public let createdTime: String
    public let href: String
    public let instructions: VerificationInstructions
    public let status: String
    public let verified: String?
    public let verified_phrases: [Bool]?
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.application = try json.decode(VerificationConstants.appModelParam)
        self.consumer = try json.decode(VerificationConstants.consumerParam)
        self.createdTime = try json.string(VerificationConstants.createdTimeParam)
        self.href = try json.string(VerificationConstants.hrefParam)
        self.instructions = try json.decode(VerificationConstants.instructionsParam)
        self.status = try json.string(VerificationConstants.statusParam)
        self.verified = try json.string(VerificationConstants.verifiedParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])
        self.verified_phrases = try json.array(VerificationConstants.verifiedPhrasesParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])?.map(Bool.init)
    }
}

/// A subset of an account's enrollments with metadata and information on where the rest are
public struct VerificationPage: JSONDecodable {
    public let limit: Int
    public let next: WebAddress?
    public let items: [Enrollment]
    public let prev: WebAddress?
    public let total: Int
    public let href: WebAddress
    public let offset: Int
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.limit = try json.int(VerificationConstants.limitParam)
        self.next = try json.string(VerificationConstants.nextParam, alongPath: [.NullBecomesNil])
        self.items = try json.array(VerificationConstants.itemsParam).map(Enrollment.init)
        self.prev = try json.string(VerificationConstants.prevParam, alongPath: [.NullBecomesNil])
        self.total = try json.int(VerificationConstants.totalParam)
        self.href = try json.string(VerificationConstants.hrefParam)
        self.offset = try json.int(VerificationConstants.offsetParam)
    }
}


/// /verifications
struct VerificationsEndpoint: SupportsJSONPosts, SupportsJSONGets {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = VerificationCreateRequest
    typealias PostResponseType = VerificationEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = VerificationPage
    
    let url: String
}

/// /verifications/{id}
public struct VerificationEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets, SupportsDeletes {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = VerificationUpdateRequest
    typealias PostResponseType = VerificationEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = Verification
    typealias DeleteHeadersType = KnurldCredentials
    
    let url: String
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.url = try json.string(VerificationConstants.hrefParam)
    }
}