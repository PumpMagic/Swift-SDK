//
//  Calls.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/18/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


private struct CallConstants {
    static let numberParam = "number"
    static let hrefParam = "href"
    
    static let audioParam = "audio"
    static let connectedTimeParam = "connectedTime"
    static let createdTimeParam = "createdTime"
    static let disconnectedTimeParam = "disconnectedTime"
    static let durationParam = "duration"
    static let errorParam = "error"
    static let statusParam = "status"
    static let timeoutParam = "timeout"
    
    static let limitParam = "limit"
    static let nextParam = "next"
    static let itemsParam = "items"
    static let prevParam = "prev"
    static let totalParam = "total"
    static let offsetParam = "offset"
}

/// All parameters involved in requesting the creation of a Knurld call.
public struct CallCreateRequest: JSONEncodable {
    public let number: String
    
    /// Initialize a request.
    public init(number: String) {
        self.number = number
    }
    
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Dictionary([CallConstants.numberParam: .String(self.number)])
    }
}

/// All parameters involved in requesting the termination of a Knurld call.
/// (There are none.)
public struct CallTerminateRequest: JSONEncodable {
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Null
    }
}

/// A call.
public struct Call: JSONDecodable {
    public let audio: String?
    public let connectedTime: String?
    public let createdTime: String
    public let disconnectedTime: String?
    public let duration: Double?
    //public let error: String?
    public let href: String
    public let number: String
    public let status: String
    public let timeout: Int
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.audio = try json.string(CallConstants.audioParam)
        self.connectedTime = try json.string(CallConstants.connectedTimeParam, alongPath: .NullBecomesNil)
        self.createdTime = try json.string(CallConstants.createdTimeParam)
        self.disconnectedTime = try json.string(CallConstants.disconnectedTimeParam, alongPath: .NullBecomesNil)
        self.duration = try json.double(CallConstants.durationParam, alongPath: .NullBecomesNil)
        self.href = try json.string(CallConstants.hrefParam)
        self.number = try json.string(CallConstants.numberParam)
        self.status = try json.string(CallConstants.statusParam)
        self.timeout = try json.int(CallConstants.timeoutParam)
    }
}

/// A subset of an account's calls with metadata and information on where the rest are.
public struct CallPage: JSONDecodable {
    public let limit: Int
    public let next: WebAddress?
    public let items: [Call]
    public let prev: WebAddress?
    public let total: Int
    public let href: WebAddress
    public let offset: Int
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.limit = try json.int(CallConstants.limitParam)
        self.next = try json.string(CallConstants.nextParam, alongPath: [.NullBecomesNil])
        self.items = try json.array(CallConstants.itemsParam).map(Call.init)
        self.prev = try json.string(CallConstants.prevParam, alongPath: [.NullBecomesNil])
        self.total = try json.int(CallConstants.totalParam)
        self.href = try json.string(CallConstants.hrefParam)
        self.offset = try json.int(CallConstants.offsetParam)
    }
}


/// /calls
struct CallsEndpoint: SupportsJSONPosts, SupportsJSONGets {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = CallCreateRequest
    typealias PostResponseType = CallEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = CallPage
    
    let url: String
}

/// A call API endpoint.
public struct CallEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = CallTerminateRequest
    typealias PostResponseType = CallEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = Call
    typealias DeleteHeadersType = KnurldCredentials
    
    public let url: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.url = try json.string(CallConstants.hrefParam)
    }
}

