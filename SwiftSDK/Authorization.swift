//
//  Authorization.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/11/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


/// Some constants associated with the Authorization endpoint and credentials
struct AuthorizationConstants {
    static let clientIDParam = "client_id"
    static let clientSecretParam = "client_secret"
    static let accessTokenParam = "access_token"
    
    static let developerIDParam = "Developer-Id"
    static let authorizationParam = "Authorization"
    
    static let developerIDPrefix = "Bearer: "
    static let authorizationPrefix = "Bearer "
}

/// StringMapRepresentable captures items that can be represented as string:string maps
/// This is for use with API endpoints that work with form bodies instead of JSON bodies
protocol StringMapRepresentable {
    func toStringMap() -> [String : String]
}

/// OAuth credentials
struct ClientCredentials: StringMapRepresentable {
    let clientID: String
    let clientSecret: String
    
    func toStringMap() -> [String : String] {
        return [AuthorizationConstants.clientIDParam: clientID, AuthorizationConstants.clientSecretParam: clientSecret]
    }
}

/// Knurld OAuth authorization response
/// @warn This is not a complete representation
struct AuthorizationResponse: JSONDecodable {
    let accessToken: String
    
    init(json: JSON) throws {
        self.accessToken = try json.string(AuthorizationConstants.accessTokenParam)
    }
}

/// Knurld credentials
struct KnurldCredentials: StringMapRepresentable {
    let developerID: String
    let authorization: String
    
    init(developerID: String, authorization: String) {
        self.developerID = developerID
        self.authorization = authorization
    }
    
    init(developerID: String, authorizationResponse: AuthorizationResponse) {
        self.developerID = developerID
        self.authorization = AuthorizationConstants.authorizationPrefix + authorizationResponse.accessToken
    }
    
    func toStringMap() -> [String : String] {
        return [AuthorizationConstants.developerIDParam: developerID, AuthorizationConstants.authorizationParam: authorization]
    }
}


extension KnurldV1API {
    /// POST /oauth/...
    /// Get OAuth credentials
    func authorize(credentials credentials: ClientCredentials, successHandler: (response: AuthorizationResponse) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = KnurldV1API.HOST + "/oauth/client_credential/accesstoken?grant_type=client_credentials"
        let body = credentials.toStringMap()
        
        requestManager.postForm(url: url, headers: nil, body: body,
                                successHandler: { json in
                                    do {
                                        let authorizationResponse = try AuthorizationResponse(json: json)
                                        successHandler(response: authorizationResponse)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError)
                                        return
                                    }
                                },
                                
                                failureHandler: { error in failureHandler(error: error) })
    }
}