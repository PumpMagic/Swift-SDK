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

/// All parameters involved in requesting the creation of a Knurld consumer.
public struct ConsumerCreateRequest: JSONEncodable {
    public let username: String
    public let password: String
    public let gender: String
    
    /// Initialize a request.
    public init(username: String, password: String, gender: String) {
        self.username = username
        self.password = password
        self.gender = gender
    }
    
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Dictionary([
            ConsumerConstants.usernameParam: .String(self.username),
            ConsumerConstants.passwordParam: .String(self.password),
            ConsumerConstants.genderParam: .String(self.gender)])
    }
}

public struct ConsumerUpdateRequest: JSONEncodable {
    public let password: String
    
    /// Initialize a request.
    public init(password: String) {
        self.password = password
    }
    
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Dictionary([ConsumerConstants.passwordParam: .String(self.password)])
    }
}

/// All parameters needed to create a Knurld consumer authentication request.
public struct ConsumerAuthenticateRequest: JSONEncodable {
    public let username: String
    public let password: String
    
    /// Initialize a request.
    public init(username: String, password: String) {
        self.username = username
        self.password = password
    }
    
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Dictionary([
            ConsumerConstants.usernameParam: .String(self.username),
            ConsumerConstants.passwordParam: .String(self.password)])
    }
}

/// A Knurld consumer.
public struct Consumer: JSONDecodable {
    public let username: String
    public let gender: String
    public let lastCompletedEnrollment: String?
    public let lastVerification: String?
    public let phrases: String
    public let role: String
    public let href: String
    
    /// Initialize from JSON.
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

/// A subset of an account's consumers with metadata and information on where the rest are.
public struct ConsumerPage: JSONDecodable {
    public let limit: Int
    public let next: WebAddress?
    public let items: [Consumer]
    public let prev: WebAddress?
    public let total: Int
    public let href: WebAddress
    public let offset: Int
    
    /// Initialize from JSON.
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

/// A consumer token, for use in generating Knurld credentials.
public struct ConsumerToken: JSONDecodable {
    public let token: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.token = try json.string(ConsumerConstants.tokenParam)
    }
}

/// Consumer credentials.
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

/// A consumer API endpoint.
public struct ConsumerEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets, SupportsDeletes {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = ConsumerUpdateRequest
    typealias PostResponseType = ConsumerEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = Consumer
    typealias DeleteHeadersType = KnurldCredentials
    
    let url: String
    
    /// Initialize from JSON.
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
