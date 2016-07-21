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



/// OAuth credentials, used to create Knurld credentials.
public struct OAuthCredentials: StringMapRepresentable {
    public let clientID: String
    public let clientSecret: String
    
    /// Initialize a set of credentials.
    public init(clientID: String, clientSecret: String) {
        self.clientID = clientID
        self.clientSecret = clientSecret
    }
    
    func toStringMap() -> [String : String] {
        return [AuthorizationConstants.clientIDParam: clientID, AuthorizationConstants.clientSecretParam: clientSecret]
    }
}


// @warn This representation is incomplete
/// Knurld OAuth authorization response.
struct AuthorizationResponse: JSONDecodable {
    let accessToken: String
    
    init(json: JSON) throws {
        self.accessToken = try json.string(AuthorizationConstants.accessTokenParam)
    }
}

/// Credentials used when working with the majority of Knurld API calls.
public struct KnurldCredentials: StringMapRepresentable {
    public let developerID: String
    public let authorization: String
    
    /// Initialize a set of credentials.
    public init(developerID: String, authorization: String) {
        self.developerID = developerID
        self.authorization = authorization
    }
    
    init(developerID: String, authorizationResponse: AuthorizationResponse) {
        self.developerID = developerID
        self.authorization = AuthorizationConstants.authorizationPrefix + authorizationResponse.accessToken
    }
    
    init(consumerToken: ConsumerToken, adminCredentials: KnurldCredentials) {
        self.developerID = AuthorizationConstants.developerIDPrefix + consumerToken.token
        self.authorization = adminCredentials.authorization
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