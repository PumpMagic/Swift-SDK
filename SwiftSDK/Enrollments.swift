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

/// All parameters involved in requesting the creation of a Knurld enrollment.
public struct EnrollmentCreateRequest: JSONEncodable {
    public let consumer: String
    public let appModel: String
    
    /// Initialize a request.
    public init(consumer: String, appModel: String) {
        self.consumer = consumer
        self.appModel = appModel
    }
    
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Dictionary([
            EnrollmentConstants.consumerParam: .String(self.consumer),
            EnrollmentConstants.appModelParam: .String(self.appModel)])
    }
}

/// An interval of time during which a phrase is spoken.
public struct EnrollmentInterval: JSONEncodable, JSONDecodable {
    public let phrase: String
    public let start: Int
    public let stop: Int
    
    /// Initialize an interval.
    public init(phrase: String, start: Int, stop: Int) {
        self.phrase = phrase
        self.start = start
        self.stop = stop
    }
    
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Dictionary([
            EnrollmentConstants.phraseParam: .String(self.phrase),
            EnrollmentConstants.startParam: .Int(self.start),
            EnrollmentConstants.stopParam: .Int(self.stop)])
    }
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.phrase = try json.string(EnrollmentConstants.phraseParam)
        self.start = try json.int(EnrollmentConstants.startParam)
        self.stop = try json.int(EnrollmentConstants.stopParam)
    }
}

/// All parameters needed to create a Knurld enrollment update request.
public struct EnrollmentUpdateRequest: JSONEncodable {
    public let enrollmentWav: WebAddress
    public let intervals: [EnrollmentInterval]
    
    /// Initialize a request.
    public init(enrollmentWav: WebAddress, intervals: [EnrollmentInterval]) {
        self.enrollmentWav = enrollmentWav
        self.intervals = intervals
    }
    
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Dictionary([
            EnrollmentConstants.enrollmentWavParam: .String(self.enrollmentWav),
            EnrollmentConstants.intervalsParam: .Array(self.intervals.map( { interval in interval.toJSON() }))
            ])
    }
}

/// Information on the application associated with an enrollment.
public struct EnrollmentApplication: JSONDecodable {
    public let href: String
    public let mode: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.mode = try json.string(EnrollmentConstants.modeParam)
    }
}

/// Information on the consumer associated with an enrollment.
public struct EnrollmentConsumer: JSONDecodable {
    public let href: String
    public let username: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.username = try json.string(EnrollmentConstants.usernameParam)
    }
}

/// Information on the phrases to speak for an enrollment.
public struct EnrollmentData: JSONDecodable {
    public let phrase: [String]
    public let repeats: Int
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.phrase = try json.array(EnrollmentConstants.phraseParam).map(String.init)
        self.repeats = try json.int(EnrollmentConstants.repeatsParam)
    }
}

/// Instruction on completing an enrollment.
public struct EnrollmentInstructions: JSONDecodable {
    public let data: EnrollmentData?
    public let directions: String
    //@todo public let optional: [???]?
    public let requires: [String]?
    public let step: Int
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.data = try json.decode(EnrollmentConstants.dataParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])
        self.directions = try json.string(EnrollmentConstants.directionsParam)
        self.requires = try json.array(EnrollmentConstants.requiresParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])?.map(String.init)
        self.step = try json.int(EnrollmentConstants.stepParam)
    }
}

/// An enrollment.
public struct Enrollment: JSONDecodable {
    public let application: EnrollmentApplication
    public let consumer: EnrollmentConsumer
    public let createdTime: String
    public let href: String
    public let instructions: EnrollmentInstructions
    public let status: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.application = try json.decode(EnrollmentConstants.appModelParam)
        self.consumer = try json.decode(EnrollmentConstants.consumerParam)
        self.createdTime = try json.string(EnrollmentConstants.createdTimeParam)
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.instructions = try json.decode(EnrollmentConstants.instructionsParam)
        self.status = try json.string(EnrollmentConstants.statusParam)
    }
}

/// A subset of an account's enrollments with metadata and information on where the rest are.
public struct EnrollmentPage: JSONDecodable {
    public let limit: Int
    public let next: WebAddress?
    public let items: [Enrollment]
    public let prev: WebAddress?
    public let total: Int
    public let href: WebAddress
    public let offset: Int
    
    /// Initialize from JSON.
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

/// An enrollment API endpoint.
public struct EnrollmentEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets, SupportsDeletes {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = EnrollmentUpdateRequest
    typealias PostResponseType = EnrollmentEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = Enrollment
    typealias DeleteHeadersType = KnurldCredentials
    
    public let url: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.url = try json.string(EnrollmentConstants.hrefParam)
    }
}