//
//  EndpointCommons.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/15/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation


struct EndpointCommons {
    static let DEFAULT_BASE_URL = "https://api.knurld.io"
    static let DEFAULT_VERSION_PATH = "/v1"
    static let DEFAULT_URL = EndpointCommons.DEFAULT_BASE_URL + EndpointCommons.DEFAULT_VERSION_PATH
    
    static let hrefParam = "href"
}

typealias WebAddress = String