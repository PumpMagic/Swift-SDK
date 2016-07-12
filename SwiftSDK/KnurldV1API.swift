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


/// KnurldV1API abstracts out version 1 of the Knurld REST API.
class KnurldV1API {
    let requestManager: HTTPRequestManager
    
    // URL constants
    static let HOST = "https://api.knurld.io"
    static let BASE_PATH = "/v1"
    static let API_URL = HOST + BASE_PATH
    
    init() {
        self.requestManager = HTTPRequestManager()
    }
    
    // For HTTP operations, see individual extensions
}

