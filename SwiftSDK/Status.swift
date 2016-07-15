//
//  Status.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/11/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


private struct ServiceStatusConstants {
    static let hrefParam = "href"
    static let nameParam = "name"
    static let versionParam = "version"
}

/// Knurld service health status
struct ServiceStatus: JSONEncodable, JSONDecodable {
    let href: WebAddress
    let name: String
    let version: String
    
    func toJSON() -> JSON {
        return .Dictionary([
            ServiceStatusConstants.hrefParam: .String(self.href),
            ServiceStatusConstants.nameParam: .String(self.name),
            ServiceStatusConstants.versionParam: .String(self.version)])
    }
    
    init(json: JSON) throws {
        self.href = try json.string(ServiceStatusConstants.hrefParam)
        self.name = try json.string(ServiceStatusConstants.nameParam)
        self.version = try json.string(ServiceStatusConstants.versionParam)
    }
}


extension KnurldV1API {
    /// Get the service status (GET /status)
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
                                failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                                return
                            }
            },
                           failureHandler: { error in failureHandler(error: error) })
    }
}