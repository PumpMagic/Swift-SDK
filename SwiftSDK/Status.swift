//
//  Status.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/11/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


/// Knurld service health status
struct ServiceStatus: JSONEncodable, JSONDecodable {
    let href: String
    let name: String
    let version: String
    
    init(json: JSON) throws {
        self.href = try json.string("href")
        self.name = try json.string("name")
        self.version = try json.string("version")
    }
    
    func toJSON() -> JSON {
        return .Dictionary([
            "href": .String(self.href),
            "name": .String(self.name),
            "version": .String(self.version)])
    }
}


extension KnurldV1API {
    /// GET /status
    /// Get the service status
    func getServiceStatus(credentials credentials: KnurldCredentials, successHandler: (status: ServiceStatus) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = KnurldV1API.API_URL + "/status"
        let headers = credentials.toStringMap()
        
        requestManager.get(url: url, headers: headers,
                           successHandler: { json in
                            do {
                                let serviceStatus = try ServiceStatus(json: json)
                                successHandler(status: serviceStatus)
                                return
                            } catch {
                                failureHandler(error: .ResponseDeserializationError)
                                return
                            }
            },
                           failureHandler: { error in failureHandler(error: error) })
    }
}