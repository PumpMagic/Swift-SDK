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
    
    //@todo consider moving non-fixed-location functions like these to the relevant endpoint classes
    func getAppModel(credentials credentials: KnurldCredentials,
                                 endpoint: AppModelEndpoint,
                                 successHandler: (AppModel) -> Void,
                                 failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func updateAppModel(credentials credentials: KnurldCredentials,
                                    endpoint: AppModelEndpoint,
                                    request: AppModelUpdateRequest,
                                    successHandler: (AppModelEndpoint) -> Void,
                                    failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.post(manager: self.requestManager, headers: credentials, body: request, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func deleteAppModel(credentials credentials: KnurldCredentials,
                                    endpoint: AppModelEndpoint,
                                    successHandler: () -> Void,
                                    failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.delete(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    
    func createConsumer(credentials credentials: KnurldCredentials,
                                    request: ConsumerCreateRequest,
                                    successHandler: (ConsumerEndpoint) -> Void,
                                    failureHandler: (HTTPRequestError) -> Void)
    {
        self.consumers.post(manager: self.requestManager, headers: credentials, body: request, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func getConsumerPage(credentials credentials: KnurldCredentials,
                                     successHandler: (ConsumerPage) -> Void,
                                     failureHandler: (HTTPRequestError) -> Void)
    {
        self.consumers.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func getConsumer(credentials credentials: KnurldCredentials,
                                 endpoint: ConsumerEndpoint,
                                 successHandler: (Consumer) -> Void,
                                 failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func updateConsumer(credentials credentials: KnurldCredentials,
                                    endpoint: ConsumerEndpoint,
                                    request: ConsumerUpdateRequest,
                                    successHandler: (ConsumerEndpoint) -> Void,
                                    failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.post(manager: self.requestManager, headers: credentials, body: request, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func deleteConsumer(credentials credentials: KnurldCredentials,
                                    endpoint: ConsumerEndpoint,
                                    successHandler: () -> Void,
                                    failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.delete(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    
    func createEnrollment(credentials credentials: KnurldCredentials,
                                      request: EnrollmentCreateRequest,
                                      successHandler: (EnrollmentEndpoint) -> Void,
                                      failureHandler: (HTTPRequestError) -> Void)
    {
        self.enrollments.post(manager: self.requestManager, headers: credentials, body: request, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func getEnrollmentPage(credentials credentials: KnurldCredentials,
                                       successHandler: (EnrollmentPage) -> Void,
                                       failureHandler: (HTTPRequestError) -> Void)
    {
        self.enrollments.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func getEnrollment(credentials credentials: KnurldCredentials,
                                   endpoint: EnrollmentEndpoint,
                                   successHandler: (Enrollment) -> Void,
                                   failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func updateEnrollment(credentials credentials: KnurldCredentials,
                                      endpoint: EnrollmentEndpoint,
                                      request: EnrollmentUpdateRequest,
                                      successHandler: (EnrollmentEndpoint) -> Void,
                                      failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.post(manager: self.requestManager, headers: credentials, body: request, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func deleteEnrollment(credentials credentials: KnurldCredentials,
                                      endpoint: EnrollmentEndpoint,
                                      successHandler: () -> Void,
                                      failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.delete(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    
    func createVerification(credentials credentials: KnurldCredentials,
                                      request: VerificationCreateRequest,
                                      successHandler: (VerificationEndpoint) -> Void,
                                      failureHandler: (HTTPRequestError) -> Void)
    {
        self.verifications.post(manager: self.requestManager, headers: credentials, body: request, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func getVerificationPage(credentials credentials: KnurldCredentials,
                                       successHandler: (VerificationPage) -> Void,
                                       failureHandler: (HTTPRequestError) -> Void)
    {
        self.verifications.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func getVerification(credentials credentials: KnurldCredentials,
                                   endpoint: VerificationEndpoint,
                                   successHandler: (Verification) -> Void,
                                   failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func updateVerification(credentials credentials: KnurldCredentials,
                                      endpoint: VerificationEndpoint,
                                      request: VerificationUpdateRequest,
                                      successHandler: (VerificationEndpoint) -> Void,
                                      failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.post(manager: self.requestManager, headers: credentials, body: request, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func deleteVerification(credentials credentials: KnurldCredentials,
                                      endpoint: VerificationEndpoint,
                                      successHandler: () -> Void,
                                      failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.delete(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    
}

