//
//  Authorization.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/11/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


protocol StringMapRepresentable {
    func toStringMap() -> [String : String]
}

/// OAuth credentials
struct ClientCredentials: StringMapRepresentable {
    let clientID: String
    let clientSecret: String
    
    func toStringMap() -> [String : String] {
        return ["client_id": clientID, "client_secret": clientSecret]
    }
}

/// Knurld OAuth authorization response
/// @warn This is not a complete representation
struct AuthorizationResponse: JSONDecodable {
    let accessToken: String
    
    init(json: JSON) throws {
        self.accessToken = try json.string("access_token")
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
        self.authorization = "Bearer \(authorizationResponse.accessToken)"
    }
    
    func toStringMap() -> [String : String] {
        return ["Developer-Id": developerID, "Authorization": authorization]
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