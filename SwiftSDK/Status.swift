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

/// Knurld service health status.
public struct ServiceStatus: JSONDecodable {
    public let href: WebAddress
    public let name: String
    public let version: String
    
    /// Initialize from JSON.
    public init(json: JSON) throws {
        self.href = try json.string(ServiceStatusConstants.hrefParam)
        self.name = try json.string(ServiceStatusConstants.nameParam)
        self.version = try json.string(ServiceStatusConstants.versionParam)
    }
}


struct StatusEndpoint: SupportsJSONGets {
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = ServiceStatus
    
    let url: String
}
