//
//  Enrollments.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/13/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


private struct EnrollmentConstants {
    static let consumerParam = "consumer"
    static let appModelParam = "app-model"
    static let hrefParam = "href"
    
    static let enrollmentWavParam = "enrollment.wav"
    static let intervalsParam = "intervals"
    
    static let phraseParam = "phrase"
    static let startParam = "start"
    static let stopParam = "stop"
    
    static let modeParam = "mode"
    static let usernameParam = "username"
    static let createdTimeParam = "createdTime"
    static let instructionsParam = "instructions"
    static let dataParam = "data"
    static let repeatsParam = "repeats"
    static let directionsParam = "directions"
    static let optionalParam = "optional"
    static let requiresParam = "requires"
    static let stepParam = "step"
    static let statusParam = "status"
    
    static let limitParam = "limit"
    static let nextParam = "next"
    static let itemsParam = "items"
    static let prevParam = "prev"
    static let totalParam = "total"
    static let offsetParam = "offset"
}

public struct EnrollmentCreateRequest: JSONEncodable, JSONDecodable {
    let consumer: String
    let appModel: String
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            EnrollmentConstants.consumerParam: .String(self.consumer),
            EnrollmentConstants.appModelParam: .String(self.appModel)])
    }
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.consumer = try json.string(EnrollmentConstants.consumerParam)
        self.appModel = try json.string(EnrollmentConstants.appModelParam)
    }
    
    public init(consumer: String, appModel: String) {
        self.consumer = consumer
        self.appModel = appModel
    }
}

public struct EnrollmentInterval: JSONEncodable, JSONDecodable {
    let phrase: String
    let start: Int
    let stop: Int
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            EnrollmentConstants.phraseParam: .String(self.phrase),
            EnrollmentConstants.startParam: .Int(self.start),
            EnrollmentConstants.stopParam: .Int(self.stop)])
    }
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.phrase = try json.string(EnrollmentConstants.phraseParam)
        self.start = try json.int(EnrollmentConstants.startParam)
        self.stop = try json.int(EnrollmentConstants.stopParam)
    }
    
    public init(phrase: String, start: Int, stop: Int) {
        self.phrase = phrase
        self.start = start
        self.stop = stop
    }
}

public struct EnrollmentUpdateRequest: JSONEncodable, JSONDecodable {
    let enrollmentWav: WebAddress
    let intervals: [EnrollmentInterval]
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            EnrollmentConstants.enrollmentWavParam: .String(self.enrollmentWav),
            EnrollmentConstants.intervalsParam: .Array(self.intervals.map( { interval in interval.toJSON() }))
            ])
    }
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.enrollmentWav = try json.string(EnrollmentConstants.enrollmentWavParam)
        self.intervals = try json.array(EnrollmentConstants.intervalsParam).map(EnrollmentInterval.init)
    }
    
    public init(enrollmentWav: WebAddress, intervals: [EnrollmentInterval]) {
        self.enrollmentWav = enrollmentWav
        self.intervals = intervals
    }
}

public struct EnrollmentApplication: JSONDecodable {
    let href: String
    let mode: String
    
    public init(json: JSON) throws {
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.mode = try json.string(EnrollmentConstants.modeParam)
    }
}

public struct EnrollmentConsumer: JSONDecodable {
    let href: String
    let username: String
    
    public init(json: JSON) throws {
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.username = try json.string(EnrollmentConstants.usernameParam)
    }
}

public struct EnrollmentData: JSONDecodable {
    let phrase: [String]
    let repeats: Int
    
    public init(json: JSON) throws {
        self.phrase = try json.array(EnrollmentConstants.phraseParam).map(String.init)
        self.repeats = try json.int(EnrollmentConstants.repeatsParam)
    }
}

public struct EnrollmentInstructions: JSONDecodable {
    let data: EnrollmentData?
    let directions: String
    //@todo let optional: [???]?
    let requires: [String]?
    let step: Int
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.data = try json.decode(EnrollmentConstants.dataParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])
        self.directions = try json.string(EnrollmentConstants.directionsParam)
        self.requires = try json.array(EnrollmentConstants.requiresParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])?.map(String.init)
        self.step = try json.int(EnrollmentConstants.stepParam)
    }
}

public struct Enrollment: JSONDecodable {
    public let application: EnrollmentApplication
    public let consumer: EnrollmentConsumer
    public let createdTime: String
    public let href: String
    public let instructions: EnrollmentInstructions
    public let status: String
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.application = try json.decode(EnrollmentConstants.appModelParam)
        self.consumer = try json.decode(EnrollmentConstants.consumerParam)
        self.createdTime = try json.string(EnrollmentConstants.createdTimeParam)
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.instructions = try json.decode(EnrollmentConstants.instructionsParam)
        self.status = try json.string(EnrollmentConstants.statusParam)
    }
}

/// A subset of an account's enrollments with metadata and information on where the rest are
public struct EnrollmentPage: JSONDecodable {
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
        self.limit = try json.int(EnrollmentConstants.limitParam)
        self.next = try json.string(EnrollmentConstants.nextParam, alongPath: [.NullBecomesNil])
        self.items = try json.array(EnrollmentConstants.itemsParam).map(Enrollment.init)
        self.prev = try json.string(EnrollmentConstants.prevParam, alongPath: [.NullBecomesNil])
        self.total = try json.int(EnrollmentConstants.totalParam)
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.offset = try json.int(EnrollmentConstants.offsetParam)
    }
}


/// /enrollments
struct EnrollmentsEndpoint: SupportsJSONPosts, SupportsJSONGets {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = EnrollmentCreateRequest
    typealias PostResponseType = EnrollmentEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = EnrollmentPage
    
    let url: String
}

/// /enrollments/{id}
public struct EnrollmentEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets, SupportsDeletes {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = EnrollmentUpdateRequest
    typealias PostResponseType = EnrollmentEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = Enrollment
    typealias DeleteHeadersType = KnurldCredentials
    
    let url: String
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.url = try json.string(EnrollmentConstants.hrefParam)
    }
}