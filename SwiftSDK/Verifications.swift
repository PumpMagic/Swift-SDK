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

struct VerificationCreateRequest: JSONEncodable, JSONDecodable {
    let consumer: String
    let appModel: String
    
    func toJSON() -> JSON {
        return .Dictionary([
            VerificationConstants.consumerParam: .String(self.consumer),
            VerificationConstants.appModelParam: .String(self.appModel)])
    }
    
    init(json: JSON) throws {
        self.consumer = try json.string(VerificationConstants.consumerParam)
        self.appModel = try json.string(VerificationConstants.appModelParam)
    }
    
    init(consumer: String, appModel: String) {
        self.consumer = consumer
        self.appModel = appModel
    }
}

struct VerificationInterval: JSONEncodable, JSONDecodable {
    let phrase: String
    let start: Int
    let stop: Int
    
    func toJSON() -> JSON {
        return .Dictionary([
            VerificationConstants.phraseParam: .String(self.phrase),
            VerificationConstants.startParam: .Int(self.start),
            VerificationConstants.stopParam: .Int(self.stop)])
    }
    
    init(json: JSON) throws {
        self.phrase = try json.string(VerificationConstants.phraseParam)
        self.start = try json.int(VerificationConstants.startParam)
        self.stop = try json.int(VerificationConstants.stopParam)
    }
    
    init(phrase: String, start: Int, stop: Int) {
        self.phrase = phrase
        self.start = start
        self.stop = stop
    }
}

struct VerificationUpdateRequest: JSONEncodable, JSONDecodable {
    let verificationWav: WebAddress
    let intervals: [VerificationInterval]
    
    func toJSON() -> JSON {
        return .Dictionary([
            VerificationConstants.verificationWavParam: .String(self.verificationWav),
            VerificationConstants.intervalsParam: .Array(self.intervals.map( { interval in interval.toJSON() }))
            ])
    }
    
    init(json: JSON) throws {
        self.verificationWav = try json.string(VerificationConstants.verificationWavParam)
        self.intervals = try json.array(VerificationConstants.intervalsParam).map(VerificationInterval.init)
    }
    
    init(verificationWav: WebAddress, intervals: [VerificationInterval]) {
        self.verificationWav = verificationWav
        self.intervals = intervals
    }
}

struct VerificationApplication: JSONDecodable {
    let href: String
    let mode: String
    
    init(json: JSON) throws {
        self.href = try json.string(VerificationConstants.hrefParam)
        self.mode = try json.string(VerificationConstants.modeParam)
    }
}

struct VerificationConsumer: JSONDecodable {
    let href: String
    let username: String
    
    init(json: JSON) throws {
        self.href = try json.string(VerificationConstants.hrefParam)
        self.username = try json.string(VerificationConstants.usernameParam)
    }
}

struct VerificationData: JSONDecodable {
    let phrase: [String]
    
    init(json: JSON) throws {
        self.phrase = try json.array(VerificationConstants.phraseParam).map(String.init)
    }
}

struct VerificationInstructions: JSONDecodable {
    let data: VerificationData?
    let directions: String
    //@todo let optional: [???]?
    let requires: [String]?
    let step: Int
    
    init(json: JSON) throws {
        self.data = try json.decode(VerificationConstants.dataParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])
        self.directions = try json.string(VerificationConstants.directionsParam)
        self.requires = try json.array(VerificationConstants.requiresParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])?.map(String.init)
        self.step = try json.int(VerificationConstants.stepParam)
    }
}

struct Verification: JSONDecodable {
    let application: VerificationApplication
    let consumer: VerificationConsumer
    let createdTime: String
    let href: String
    let instructions: VerificationInstructions
    let status: String
    let verified: String?
    let verified_phrases: [Bool]?
    
    init(json: JSON) throws {
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
struct VerificationPage: JSONDecodable {
    let limit: Int
    let next: WebAddress?
    let items: [Enrollment]
    let prev: WebAddress?
    let total: Int
    let href: WebAddress
    let offset: Int
    
    init(json: JSON) throws {
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
    
    let url = KnurldV1API.API_URL + "/verifications"
}

/// /verifications/{id}
struct VerificationEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets, SupportsDeletes {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = VerificationUpdateRequest
    typealias PostResponseType = VerificationEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = Verification
    typealias DeleteHeadersType = KnurldCredentials
    
    let url: String
    
    init(json: JSON) throws {
        self.url = try json.string(KnurldV1APIConstants.hrefParam)
    }
}