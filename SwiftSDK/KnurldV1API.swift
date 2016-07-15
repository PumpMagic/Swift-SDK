//
//  KnurldV1API.swift
//  SwiftSDK
//
//  An abstraction of version 1 of the Knurld REST API.
//
//  Created by Ryan Conway on 7/6/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


typealias WebAddress = String

struct KnurldV1APIConstants {
    static let hrefParam = "href"
}

protocol KnurldResource {}

struct ResourceLocator<ResourceType: KnurldResource>: JSONDecodable {
    let href: WebAddress
    
    init(json: JSON) throws {
        self.href = try json.string(KnurldV1APIConstants.hrefParam)
    }
    
    init(href: String) {
        self.href = href
    }
    
    func getURL() -> String { return self.href }
}

/// KnurldV1API abstracts out version 1 of the Knurld REST API.
class KnurldV1API {
    let requestManager: HTTPRequestManager
    let authorization: AuthorizationEndpoint
    let appModels: RESTEndpointFamily<AppModel, AppModelPage, AppModelCreateRequest, AppModelUpdateRequest>
    let consumers: RESTEndpointFamily<Consumer, ConsumerPage, ConsumerCreateRequest, ConsumerUpdateRequest>
    let enrollments: RESTEndpointFamily<Enrollment, EnrollmentPage, EnrollmentCreateRequest, EnrollmentUpdateRequest>
    let verifications: RESTEndpointFamily<Verification, VerificationPage, VerificationCreateRequest, VerificationUpdateRequest>
    
    // URL constants
    static let HOST = "https://api.knurld.io"
    static let BASE_PATH = "/v1"
    static let API_URL = HOST + BASE_PATH
    
    init() {
        self.requestManager = HTTPRequestManager()
        self.authorization = AuthorizationEndpoint(requestManager: self.requestManager)
        self.appModels = RESTEndpointFamily(url: KnurldV1API.API_URL + "/app-models", requestManager: self.requestManager)
        self.consumers = RESTEndpointFamily(url: KnurldV1API.API_URL + "/consumers", requestManager: self.requestManager)
        self.enrollments = RESTEndpointFamily(url: KnurldV1API.API_URL + "/enrollments", requestManager: self.requestManager)
        self.verifications = RESTEndpointFamily(url: KnurldV1API.API_URL + "/verifications", requestManager: self.requestManager)
    }
    
    // For HTTP operations, see individual extensions
}

