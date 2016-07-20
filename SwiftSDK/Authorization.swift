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



/// OAuth credentials
public struct OAuthCredentials: StringMapRepresentable {
    let clientID: String
    let clientSecret: String
    
    public init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    func toStringMap() -> [String : String] {
        return [AuthorizationConstants.clientIDParam: clientID, AuthorizationConstants.clientSecretParam: clientSecret]
    }
}

/// Knurld OAuth authorization response
/// @warn This representation is incomplete
struct AuthorizationResponse: JSONDecodable {
    let accessToken: String
    
    init(json: JSON) throws {
        self.accessToken = try json.string(AuthorizationConstants.accessTokenParam)
    }
}

/// Knurld credentials
public struct KnurldCredentials: StringMapRepresentable {
    let developerID: String
    let authorization: String
    
    public init(developerID: String, authorization: String) {
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




/// /oauth/client_credential/accesstoken?grant_type=client_credentials
struct AuthorizationEndpoint: SupportsHeaderlessStringMapPosts {
    typealias PostRequestType = OAuthCredentials
    typealias PostResponseType = AuthorizationResponse
    
    let url: String
}