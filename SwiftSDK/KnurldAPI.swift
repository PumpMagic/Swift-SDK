//
//  KnurldAPI.swift
//  SwiftSDK
//
//  An abstraction of the Knurld web API.
//
//  Created by Ryan Conway on 7/6/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation


/// KnurldAPI abstracts out the Knurld web API.
public class KnurldAPI {
    let requestManager: HTTPRequestManager
    
    let baseURL: String
    let versionPath: String
    var url: String { get { return self.baseURL + self.versionPath } }
    
    // Endpoints with fixed locations
    let authorization: AuthorizationEndpoint
    let status: StatusEndpoint
    let appModels: AppModelsEndpoint
    let consumers: ConsumersEndpoint
    let authenticateConsumerEndpoint: AuthenticateConsumerEndpoint
    let enrollments: EnrollmentsEndpoint
    let verifications: VerificationsEndpoint
    let urlEndpointAnalysis: URLEndpointAnalysisEndpoint
    
    /// Initialize a Knurld API using a custom URL and version path, instead of e.g. "https://api.knurld.io" and "/v1"
    init(baseURL: String, versionPath: String) {
        self.requestManager = HTTPRequestManager()
        
        self.baseURL = baseURL
        self.versionPath = versionPath
        
        let url = self.baseURL + self.versionPath
        self.authorization = AuthorizationEndpoint(url: self.baseURL + "/oauth/client_credential/accesstoken?grant_type=client_credentials")
        self.status = StatusEndpoint(url: url + "/status")
        self.appModels = AppModelsEndpoint(url: url + "/app-models")
        self.consumers = ConsumersEndpoint(url: url + "/consumers")
        self.authenticateConsumerEndpoint = AuthenticateConsumerEndpoint(url: url + "/consumers/token")
        self.enrollments = EnrollmentsEndpoint(url: url + "/enrollments")
        self.verifications = VerificationsEndpoint(url: url + "/verifications")
        self.urlEndpointAnalysis = URLEndpointAnalysisEndpoint(url: url + "/endpointAnalysis/url")
    }
    
    /// Initialize a Knurld API using a custom URL, instead of e.g. "https://api.knurld.io"
    public convenience init(url: String) {
        self.init(baseURL: url, versionPath: EndpointCommons.DEFAULT_VERSION_PATH)
    }
    
    /// Initialize a Knurld API using the default URL
    public convenience init() {
        self.init(baseURL: EndpointCommons.DEFAULT_BASE_URL, versionPath: EndpointCommons.DEFAULT_VERSION_PATH)
    }
    
    
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
    
    
    func endpointURL(credentials credentials: KnurldCredentials,
                                 request: URLEndpointAnalysisCreateRequest,
                                 successHandler: (EndpointAnalysisEndpoint) -> Void,
                                 failureHandler: (HTTPRequestError) -> Void)
    {
        urlEndpointAnalysis.post(manager: self.requestManager,
                                 headers: credentials,
                                 body: request,
                                 successHandler: { summary in
                                    successHandler(EndpointAnalysisEndpoint(summary: summary)) },
                                 failureHandler: failureHandler)
    }
    
    func getEndpointingStatus(credentials credentials: KnurldCredentials,
                                          endpoint: EndpointAnalysisEndpoint,
                                          successHandler: (EndpointAnalysis) -> Void,
                                          failureHandler: (HTTPRequestError) -> Void)
    {
        endpoint.get(manager: self.requestManager, headers: credentials, successHandler: successHandler, failureHandler: failureHandler)
    }
}

