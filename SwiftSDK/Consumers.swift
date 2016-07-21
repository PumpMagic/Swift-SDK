//
//  Consumers.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/12/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


private struct ConsumerConstants {
    static let hrefParam = "href"
    static let usernameParam = "username"
    static let passwordParam = "password"
    static let genderParam = "gender"
    static let lastCompletedEnrollmentParam = "lastCompletedEnrollment"
    static let lastVerificationParam = "lastVerification"
    static let phrasesParam = "phrases"
    static let roleParam = "role"
    static let tokenParam = "token"
    static let limitParam = "limit"
    static let nextParam = "next"
    static let itemsParam = "items"
    static let prevParam = "prev"
    static let totalParam = "total"
    static let offsetParam = "offset"
}

public struct ConsumerCreateRequest: JSONEncodable, JSONDecodable {
    public let username: String
    public let password: String
    public let gender: String
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            ConsumerConstants.usernameParam: .String(self.username),
            ConsumerConstants.passwordParam: .String(self.password),
            ConsumerConstants.genderParam: .String(self.gender)])
    }
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.username = try json.string(ConsumerConstants.usernameParam)
        self.password = try json.string(ConsumerConstants.passwordParam)
        self.gender = try json.string(ConsumerConstants.genderParam)
    }
    
    public init(username: String, password: String, gender: String) {
        self.username = username
        self.password = password
        self.gender = gender
    }
}

public struct ConsumerUpdateRequest: JSONEncodable, JSONDecodable {
    public let password: String
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([ConsumerConstants.passwordParam: .String(self.password)])
    }
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.password = try json.string(ConsumerConstants.passwordParam)
    }
    
    public init(password: String) {
        self.password = password
    }
}

public struct ConsumerAuthenticateRequest: JSONEncodable, JSONDecodable {
    public let username: String
    public let password: String
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            ConsumerConstants.usernameParam: .String(self.username),
            ConsumerConstants.passwordParam: .String(self.password)])
    }
    
    public init(json: JSON) throws {
        self.username = try json.string(ConsumerConstants.usernameParam)
        self.password = try json.string(ConsumerConstants.passwordParam)
    }
    
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

public struct Consumer: JSONDecodable {
    public let username: String
    public let gender: String
    public let lastCompletedEnrollment: String?
    public let lastVerification: String?
    public let phrases: String
    public let role: String
    public let href: String
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.username = try json.string(ConsumerConstants.usernameParam)
        self.gender = try json.string(ConsumerConstants.genderParam)
        self.lastCompletedEnrollment = try json.string(ConsumerConstants.lastCompletedEnrollmentParam, alongPath: .NullBecomesNil)
        self.lastVerification = try json.string(ConsumerConstants.lastVerificationParam, alongPath: .NullBecomesNil)
        self.phrases = try json.string(ConsumerConstants.phrasesParam)
        self.role = try json.string(ConsumerConstants.roleParam)
        self.href = try json.string(ConsumerConstants.hrefParam)
    }
}

/// A subset of an account's consumers with metadata and information on where the rest are
public struct ConsumerPage: JSONDecodable {
    public let limit: Int
    public let next: WebAddress?
    public let items: [Consumer]
    public let prev: WebAddress?
    public let total: Int
    public let href: WebAddress
    public let offset: Int
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.limit = try json.int(ConsumerConstants.limitParam)
        self.next = try json.string(ConsumerConstants.nextParam, alongPath: [.NullBecomesNil])
        self.items = try json.array(ConsumerConstants.itemsParam).map(Consumer.init)
        self.prev = try json.string(ConsumerConstants.prevParam, alongPath: [.NullBecomesNil])
        self.total = try json.int(ConsumerConstants.totalParam)
        self.href = try json.string(ConsumerConstants.hrefParam)
        self.offset = try json.int(ConsumerConstants.offsetParam)
    }
}

public struct ConsumerToken: JSONEncodable, JSONDecodable {
    public let token: String
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([ConsumerConstants.tokenParam: .String(self.token)])
    }
    
    public init(json: JSON) throws {
        self.token = try json.string(ConsumerConstants.tokenParam)
    }
}

/// Knurld credentials
public struct ConsumerCredentials: StringMapRepresentable {
    public let developerID: String
    public let authorization: String
    
    init(developerID: String, authorization: String) {
        self.developerID = developerID
        self.authorization = authorization
    }
    
    init(consumerToken: ConsumerToken, authorizationResponse: AuthorizationResponse) {
        self.developerID = AuthorizationConstants.developerIDPrefix + consumerToken.token
        self.authorization = AuthorizationConstants.authorizationPrefix + authorizationResponse.accessToken
    }
    
    func toStringMap() -> [String : String] {
        return [AuthorizationConstants.developerIDParam: developerID, AuthorizationConstants.authorizationParam: authorization]
    }
}


/// /consumers
struct ConsumersEndpoint: SupportsJSONPosts, SupportsJSONGets {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = ConsumerCreateRequest
    typealias PostResponseType = ConsumerEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = ConsumerPage
    
    let url: String
}

/// /consumers/{id}
public struct ConsumerEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets, SupportsDeletes {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = ConsumerUpdateRequest
    typealias PostResponseType = ConsumerEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = Consumer
    typealias DeleteHeadersType = KnurldCredentials
    
    let url: String
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.url = try json.string(ConsumerConstants.hrefParam)
    }
}

struct AuthenticateConsumerEndpoint: SupportsJSONPosts {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = ConsumerAuthenticateRequest
    typealias PostResponseType = ConsumerToken
    
    let url: String
}
