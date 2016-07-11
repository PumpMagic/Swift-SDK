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


// URL constants
let HOST = "https://api.knurld.io"
let BASE_PATH = "/v1"
let API_URL = HOST + BASE_PATH

// String constants
let DEVELOPER_ID_PARAM_NAME = "Developer-Id"
let AUTHORIZATION_PARAM_NAME = "Authorization"


/// KnurldV1API abstracts out version 1 of the Knurld REST API.
class KnurldV1API {
    private let requestManager: HTTPRequestManager
    
    init() {
        self.requestManager = HTTPRequestManager()
    }
    
    private func makeAuthHeaders(developerID developerID: String, authorization: String) -> [String : String] {
        return [DEVELOPER_ID_PARAM_NAME: developerID, AUTHORIZATION_PARAM_NAME: "Bearer \(authorization)"]
    }
    
    /// POST /oauth/...
    func authorize(clientID clientID: String, clientSecret: String, successHandler: (accessToken: String) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = HOST + "/oauth/client_credential/accesstoken?grant_type=client_credentials"
        let body = ["client_id": clientID, "client_secret": clientSecret]
        
        requestManager.postForm(url: url, headers: nil, body: body,
                                successHandler: { json in
                                    do {
                                        let accessToken = try json.string("access_token")
                                        successHandler(accessToken: accessToken)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError)
                                        return
                                    }
                                },
            
                                failureHandler: { error in failureHandler(error: error) })
    }
    
    /// GET /status
    func getServiceStatus(developerID developerID: String, authorization: String, successHandler: (href: String, name: String, version: String) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = API_URL + "/status"
        let headers = makeAuthHeaders(developerID: developerID, authorization: authorization)
        
        requestManager.get(url: url, headers: headers,
                           successHandler: { json in
                                print("JSON: \(json)")
                            
                                do {
                                    let href = try json.string("href")
                                    let name = try json.string("name")
                                    let version = try json.string("version")
                                    successHandler(href: href, name: name, version: version)
                                    return
                                } catch {
                                    failureHandler(error: .ResponseDeserializationError)
                                    return
                                }
                            },
                           failureHandler: { error in failureHandler(error: error) })
    }
    
    /// POST /app-models
    func createAppModel(developerID developerID: String, authorization: String, params: AppModelParams, successHandler: (href: String) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = API_URL + "/app-models"
        let headers = makeAuthHeaders(developerID: developerID, authorization: authorization)
        let parameters = params.toJSON()
        
        requestManager.postJSON(url: url, headers: headers, body: parameters,
                                successHandler: { json in
                                    print("JSON: \(json)")
                                    
                                    do {
                                        let href = try json.string("href")
                                        successHandler(href: href)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError)
                                        return
                                    }
                                },
                                failureHandler: { error in failureHandler(error: error) })
    }
}

struct AppModelParams: JSONDecodable, JSONEncodable {
    let enrollmentRepeats: Int
    let vocabulary: [String]
    let verificationLength: Int
    let threshold: Double?
    let autoThresholdEnable: Bool?
    let autoThresholdClearance: Int?
    let autoThresholdMaxRise: Int?
    let useModelUpdate: Bool?
    let modelUpdateDailyLimit: Int?
    
    init(enrollmentRepeats: Int, vocabulary: [String], verificationLength: Int) {
        self.enrollmentRepeats = enrollmentRepeats
        self.vocabulary = vocabulary
        self.verificationLength = verificationLength
        self.threshold = nil
        self.autoThresholdEnable = nil
        self.autoThresholdClearance = nil
        self.autoThresholdMaxRise = nil
        self.useModelUpdate = nil
        self.modelUpdateDailyLimit = nil
    }
    
    init(json: JSON) throws {
        self.enrollmentRepeats = try json.int("enrollmentRepeats")
        self.vocabulary = try json.array("vocabulary").map(String.init)
        self.verificationLength = try json.int("verificationLength")
        
        self.threshold = try json.double("threshold", alongPath: [.MissingKeyBecomesNil, .NullBecomesNil])
        self.autoThresholdEnable = try json.bool("autoThresholdEnable", alongPath: [.MissingKeyBecomesNil, .NullBecomesNil])
        self.autoThresholdClearance = try json.int("autoThresholdClearance", alongPath: [.MissingKeyBecomesNil, .NullBecomesNil])
        self.autoThresholdMaxRise = try json.int("autoThresholdMaxRise", alongPath: [.MissingKeyBecomesNil, .NullBecomesNil])
        self.useModelUpdate = try json.bool("useModelUpdate", alongPath: [.MissingKeyBecomesNil, .NullBecomesNil])
        self.modelUpdateDailyLimit = try json.int("modelUpdateDailyLimit", alongPath: [.MissingKeyBecomesNil, .NullBecomesNil])
    }
    
    func toJSON() -> JSON {
        var json: [String : Freddy.JSON] = [
            "enrollmentRepeats": .Int(self.enrollmentRepeats),
            "vocabulary": .Array(self.vocabulary.map(JSON.String)),
            "verificationLength": .Int(self.verificationLength)]
        
        if let threshold = self.threshold {
            json.updateValue(JSON.Double(threshold), forKey: "threshold")
        }
        if let autoThresholdEnable = self.autoThresholdEnable {
            json.updateValue(JSON.Bool(autoThresholdEnable), forKey: "autoThresholdEnable")
        }
        if let autoThresholdClearance = self.autoThresholdClearance {
            json.updateValue(JSON.Int(autoThresholdClearance), forKey: "autoThresholdClearance")
        }
        if let autoThresholdMaxRise = self.autoThresholdMaxRise {
            json.updateValue(JSON.Int(autoThresholdMaxRise), forKey: "autoThresholdMaxRise")
        }
        if let useModelUpdate = self.useModelUpdate {
            json.updateValue(JSON.Bool(useModelUpdate), forKey: "useModelUpdate")
        }
        if let modelUpdateDailyLimit = self.modelUpdateDailyLimit {
            json.updateValue(JSON.Int(modelUpdateDailyLimit), forKey: "modelUpdateDailyLimit")
        }
        
        return .Dictionary(json)
    }
}
