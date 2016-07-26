//
//  Verifications.swift
//  KnurldSDK
//
//  Created by Ryan Conway on 7/14/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


private struct VerificationConstants {
    static let consumerParam = "consumer"
    static let appModelParam = "app-model"
    static let hrefParam = "href"
    
    static let verificationWavParam = "verification.wav"
    static let intervalsParam = "intervals"
    
    static let phraseParam = "phrase"
    static let phrasesParam = "phrases"
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

/// All parameters involved in requesting the creation of a Knurld verification.
public struct VerificationCreateRequest: JSONEncodable {
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
            VerificationConstants.consumerParam: .String(self.consumer),
            VerificationConstants.appModelParam: .String(self.appModel)])
    }
}

/// An interval of time during which a phrase is spoken.
public struct VerificationInterval: JSONEncodable, JSONDecodable {
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
            VerificationConstants.phraseParam: .String(self.phrase),
            VerificationConstants.startParam: .Int(self.start),
            VerificationConstants.stopParam: .Int(self.stop)])
    }
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.phrase = try json.string(VerificationConstants.phraseParam)
        self.start = try json.int(VerificationConstants.startParam)
        self.stop = try json.int(VerificationConstants.stopParam)
    }
}

/// All parameters needed to create a Knurld verification update request.
public struct VerificationUpdateRequest: JSONEncodable {
    public let verificationWav: WebAddress
    public let intervals: [VerificationInterval]
    
    /// Initialize a request.
    public init(verificationWav: WebAddress, intervals: [VerificationInterval]) {
        self.verificationWav = verificationWav
        self.intervals = intervals
    }
    
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Dictionary([
            VerificationConstants.verificationWavParam: .String(self.verificationWav),
            VerificationConstants.intervalsParam: .Array(self.intervals.map( { interval in interval.toJSON() }))
            ])
    }
}

/// Information on the application associated with a verification.
public struct VerificationApplication: JSONDecodable {
    public let href: String
    public let mode: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.href = try json.string(VerificationConstants.hrefParam)
        self.mode = try json.string(VerificationConstants.modeParam)
    }
}

/// Information on the consumer associated with a verification.
public struct VerificationConsumer: JSONDecodable {
    public let href: String
    public let username: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.href = try json.string(VerificationConstants.hrefParam)
        self.username = try json.string(VerificationConstants.usernameParam)
    }
}

/// Information on the phrases spoken in a verification.
public struct VerificationData: JSONDecodable {
    public let phrases: [String]
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.phrases = try json.array(VerificationConstants.phrasesParam).map(String.init)
    }
}

/// Instruction on completing a verification.
public struct VerificationInstructions: JSONDecodable {
    public let data: VerificationData?
    public let directions: String
    //@todo let optional: [???]?
    public let requires: [String]?
    public let step: Int
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.data = try json.decode(VerificationConstants.dataParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])
        self.directions = try json.string(VerificationConstants.directionsParam)
        self.requires = try json.array(VerificationConstants.requiresParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])?.map(String.init)
        self.step = try json.int(VerificationConstants.stepParam)
    }
}

/// A verification.
public struct Verification: JSONDecodable {
    public let application: VerificationApplication
    public let consumer: VerificationConsumer
    public let createdTime: String
    public let href: String
    public let instructions: VerificationInstructions
    public let status: String
    public let verified: Bool?
    public let verified_phrases: [Bool]?
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.application = try json.decode(VerificationConstants.appModelParam)
        self.consumer = try json.decode(VerificationConstants.consumerParam)
        self.createdTime = try json.string(VerificationConstants.createdTimeParam)
        self.href = try json.string(VerificationConstants.hrefParam)
        self.instructions = try json.decode(VerificationConstants.instructionsParam)
        self.status = try json.string(VerificationConstants.statusParam)
        self.verified = try json.bool(VerificationConstants.verifiedParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])
        self.verified_phrases = try json.array(VerificationConstants.verifiedPhrasesParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])?.map(Bool.init)
    }
}

/// A subset of an account's verifications with metadata and information on where the rest are.
public struct VerificationPage: JSONDecodable {
    public let limit: Int
    public let next: WebAddress?
    public let items: [Verification]
    public let prev: WebAddress?
    public let total: Int
    public let href: WebAddress
    public let offset: Int
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.limit = try json.int(VerificationConstants.limitParam)
        self.next = try json.string(VerificationConstants.nextParam, alongPath: [.NullBecomesNil])
        self.items = try json.array(VerificationConstants.itemsParam).map(Verification.init)
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

/// A verification API endpoint.
public struct VerificationEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets, SupportsDeletes {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = VerificationUpdateRequest
    typealias PostResponseType = VerificationEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = Verification
    typealias DeleteHeadersType = KnurldCredentials
    
    public let url: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.url = try json.string(VerificationConstants.hrefParam)
    }
}