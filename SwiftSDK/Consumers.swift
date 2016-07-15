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

struct ConsumerCreateRequest: JSONEncodable, JSONDecodable {
    let username: String
    let password: String
    let gender: String
    
    func toJSON() -> JSON {
        return .Dictionary([
            ConsumerConstants.usernameParam: .String(self.username),
            ConsumerConstants.passwordParam: .String(self.password),
            ConsumerConstants.genderParam: .String(self.gender)])
    }
    
    init(json: JSON) throws {
        self.username = try json.string(ConsumerConstants.usernameParam)
        self.password = try json.string(ConsumerConstants.passwordParam)
        self.gender = try json.string(ConsumerConstants.genderParam)
    }
    
    init(username: String, password: String, gender: String) {
        self.username = username
        self.password = password
        self.gender = gender
    }
}

struct ConsumerUpdateRequest: JSONEncodable, JSONDecodable {
    let password: String
    
    func toJSON() -> JSON {
        return .Dictionary([ConsumerConstants.passwordParam: .String(self.password)])
    }
    
    init(json: JSON) throws {
        self.password = try json.string(ConsumerConstants.passwordParam)
    }
    
    init(password: String) {
        self.password = password
    }
}

struct ConsumerAuthenticateRequest: JSONEncodable, JSONDecodable {
    let username: String
    let password: String
    
    func toJSON() -> JSON {
        return .Dictionary([
            ConsumerConstants.usernameParam: .String(self.username),
            ConsumerConstants.passwordParam: .String(self.password)])
    }
    
    init(json: JSON) throws {
        self.username = try json.string(ConsumerConstants.usernameParam)
        self.password = try json.string(ConsumerConstants.passwordParam)
    }
    
    init(username: String, password: String) {
        self.username = username
        self.password = password
    }
}

struct Consumer: JSONDecodable {
    let username: String
    let gender: String
    let lastCompletedEnrollment: String?
    let lastVerification: String?
    let phrases: String
    let role: String
    let href: String
    
    init(json: JSON) throws {
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
struct ConsumerPage: JSONDecodable {
    let limit: Int
    let next: WebAddress?
    let items: [Consumer]
    let prev: WebAddress?
    let total: Int
    let href: WebAddress
    let offset: Int
    
    init(json: JSON) throws {
        self.limit = try json.int(ConsumerConstants.limitParam)
        self.next = try json.string(ConsumerConstants.nextParam, alongPath: [.NullBecomesNil])
        self.items = try json.array(ConsumerConstants.itemsParam).map(Consumer.init)
        self.prev = try json.string(ConsumerConstants.prevParam, alongPath: [.NullBecomesNil])
        self.total = try json.int(ConsumerConstants.totalParam)
        self.href = try json.string(ConsumerConstants.hrefParam)
        self.offset = try json.int(ConsumerConstants.offsetParam)
    }
}

struct ConsumerToken: JSONEncodable, JSONDecodable {
    let token: String
    
    func toJSON() -> JSON {
        return .Dictionary([ConsumerConstants.tokenParam: .String(self.token)])
    }
    
    init(json: JSON) throws {
        self.token = try json.string(ConsumerConstants.tokenParam)
    }
}

/// Knurld credentials
struct ConsumerCredentials: StringMapRepresentable {
    let developerID: String
    let authorization: String
    
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
    
    let url = KnurldV1API.API_URL + "/consumers"
}

/// /consumers/{id}
struct ConsumerEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets, SupportsDeletes {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = ConsumerUpdateRequest
    typealias PostResponseType = ConsumerEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = Consumer
    typealias DeleteHeadersType = KnurldCredentials
    
    let url: String
    
    init(json: JSON) throws {
        self.url = try json.string(KnurldV1APIConstants.hrefParam)
    }
}

//@todo model using SupportsJSONPosts
extension KnurldV1API {
    func authenticateConsumer(credentials credentials: KnurldCredentials, request: ConsumerAuthenticateRequest, successHandler: (token: ConsumerToken) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = KnurldV1API.API_URL + "/consumers/token"
        let headers = credentials.toStringMap()
        let parameters = request.toJSON()
        
        requestManager.postJSON(url: url, headers: headers, body: parameters,
                                successHandler: { json in
                                    do {
                                        let token = try ConsumerToken(json: json)
                                        successHandler(token: token)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                                        return
                                    }
                                },
                                failureHandler: { error in failureHandler(error: error) })
    }
}