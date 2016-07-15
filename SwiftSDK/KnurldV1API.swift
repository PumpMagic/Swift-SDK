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

/// KnurldV1API abstracts out version 1 of the Knurld REST API.
class KnurldV1API {
    let requestManager: HTTPRequestManager
    
    let authorization: AuthorizationEndpoint
    let status: StatusEndpoint
    let appModels: AppModelsEndpoint
    let consumers: ConsumersEndpoint
    let enrollments: EnrollmentsEndpoint
    let verifications: VerificationsEndpoint
    
    // URL constants
    static let HOST = "https://api.knurld.io"
    static let BASE_PATH = "/v1"
    static let API_URL = HOST + BASE_PATH
    
    init() {
        self.requestManager = HTTPRequestManager()
        self.authorization = AuthorizationEndpoint()
        self.status = StatusEndpoint()
        self.appModels = AppModelsEndpoint()
        self.consumers = ConsumersEndpoint()
        self.enrollments = EnrollmentsEndpoint()
        self.verifications = VerificationsEndpoint()
    }
    
    // For HTTP operations, see individual extensions
    
    // Aliases (consider moving these to a higher abstraction)
    func authorize(credentials credentials: OAuthCredentials,
                               developerID: String,
                               successHandler: (knurldCredentials: KnurldCredentials) -> Void,
                               failureHandler: (error: HTTPRequestError) -> Void)
    {
        self.authorization.post(manager: self.requestManager, headers: (), body: credentials,
                                successHandler: { response in
                                    successHandler(knurldCredentials: KnurldCredentials(developerID: developerID, authorizationResponse: response))
                                },
                                failureHandler: failureHandler)
    }
    
    func getStatus(credentials credentials: KnurldCredentials,
                               successHandler: (ServiceStatus) -> Void,
                               failureHandler: (HTTPRequestError) -> Void)
    {
        self.status.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func createAppModel(credentials credentials: KnurldCredentials,
                                    request: AppModelCreateRequest,
                                    successHandler: (AppModelEndpoint) -> Void,
                                    failureHandler: (HTTPRequestError) -> Void)
    {
        self.appModels.post(manager: self.requestManager, headers: credentials, body: request, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func getAppModelPage(credentials credentials: KnurldCredentials,
                                     successHandler: (AppModelPage) -> Void,
                                     failureHandler: (HTTPRequestError) -> Void)
    {
        self.appModels.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
}

