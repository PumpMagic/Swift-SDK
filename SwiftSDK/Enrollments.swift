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

struct EnrollmentCreateRequest: JSONEncodable, JSONDecodable {
    let consumer: String
    let appModel: String
    
    func toJSON() -> JSON {
        return .Dictionary([
            EnrollmentConstants.consumerParam: .String(self.consumer),
            EnrollmentConstants.appModelParam: .String(self.appModel)])
    }
    
    init(json: JSON) throws {
        self.consumer = try json.string(EnrollmentConstants.consumerParam)
        self.appModel = try json.string(EnrollmentConstants.appModelParam)
    }
    
    init(consumer: String, appModel: String) {
        self.consumer = consumer
        self.appModel = appModel
    }
}

struct EnrollmentInterval: JSONEncodable, JSONDecodable {
    let phrase: String
    let start: Int
    let stop: Int
    
    func toJSON() -> JSON {
        return .Dictionary([
            EnrollmentConstants.phraseParam: .String(self.phrase),
            EnrollmentConstants.startParam: .Int(self.start),
            EnrollmentConstants.stopParam: .Int(self.stop)])
    }
    
    init(json: JSON) throws {
        self.phrase = try json.string(EnrollmentConstants.phraseParam)
        self.start = try json.int(EnrollmentConstants.startParam)
        self.stop = try json.int(EnrollmentConstants.stopParam)
    }
    
    init(phrase: String, start: Int, stop: Int) {
        self.phrase = phrase
        self.start = start
        self.stop = stop
    }
}

struct EnrollmentUpdateRequest: JSONEncodable, JSONDecodable {
    let enrollmentWav: WebAddress
    let intervals: [EnrollmentInterval]
    
    func toJSON() -> JSON {
        return .Dictionary([
            EnrollmentConstants.enrollmentWavParam: .String(self.enrollmentWav),
            EnrollmentConstants.intervalsParam: .Array(self.intervals.map( { interval in interval.toJSON() }))
            ])
    }
    
    init(json: JSON) throws {
        self.enrollmentWav = try json.string(EnrollmentConstants.enrollmentWavParam)
        self.intervals = try json.array(EnrollmentConstants.intervalsParam).map(EnrollmentInterval.init)
    }
    
    init(enrollmentWav: WebAddress, intervals: [EnrollmentInterval]) {
        self.enrollmentWav = enrollmentWav
        self.intervals = intervals
    }
}

struct EnrollmentApplication: JSONDecodable {
    let href: String
    let mode: String
    
    init(json: JSON) throws {
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.mode = try json.string(EnrollmentConstants.modeParam)
    }
}

struct EnrollmentConsumer: JSONDecodable {
    let href: String
    let username: String
    
    init(json: JSON) throws {
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.username = try json.string(EnrollmentConstants.usernameParam)
    }
}

struct EnrollmentData: JSONDecodable {
    let phrase: [String]
    let repeats: Int
    
    init(json: JSON) throws {
        self.phrase = try json.array(EnrollmentConstants.phraseParam).map(String.init)
        self.repeats = try json.int(EnrollmentConstants.repeatsParam)
    }
}

struct EnrollmentInstructions: JSONDecodable {
    let data: EnrollmentData?
    let directions: String
    //@todo let optional: [???]?
    let requires: [String]?
    let step: Int
    
    init(json: JSON) throws {
        self.data = try json.decode(EnrollmentConstants.dataParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])
        self.directions = try json.string(EnrollmentConstants.directionsParam)
        self.requires = try json.array(EnrollmentConstants.requiresParam, alongPath: [.NullBecomesNil, .MissingKeyBecomesNil])?.map(String.init)
        self.step = try json.int(EnrollmentConstants.stepParam)
    }
}

struct Enrollment: KnurldResource, JSONDecodable {
    let application: EnrollmentApplication
    let consumer: EnrollmentConsumer
    let createdTime: String
    let locator: ResourceLocator<Enrollment>
    let instructions: EnrollmentInstructions
    let status: String
    
    init(json: JSON) throws {
        self.application = try json.decode(EnrollmentConstants.appModelParam)
        self.consumer = try json.decode(EnrollmentConstants.consumerParam)
        self.createdTime = try json.string(EnrollmentConstants.createdTimeParam)
        self.locator = try json.decode()
        self.instructions = try json.decode(EnrollmentConstants.instructionsParam)
        self.status = try json.string(EnrollmentConstants.statusParam)
    }
}

/// A subset of an account's enrollments with metadata and information on where the rest are
struct EnrollmentPage: JSONDecodable {
    let limit: Int
    let next: WebAddress?
    let items: [Enrollment]
    let prev: WebAddress?
    let total: Int
    let href: WebAddress
    let offset: Int
    
    init(json: JSON) throws {
        self.limit = try json.int(EnrollmentConstants.limitParam)
        self.next = try json.string(EnrollmentConstants.nextParam, alongPath: [.NullBecomesNil])
        self.items = try json.array(EnrollmentConstants.itemsParam).map(Enrollment.init)
        self.prev = try json.string(EnrollmentConstants.prevParam, alongPath: [.NullBecomesNil])
        self.total = try json.int(EnrollmentConstants.totalParam)
        self.href = try json.string(EnrollmentConstants.hrefParam)
        self.offset = try json.int(EnrollmentConstants.offsetParam)
    }
}