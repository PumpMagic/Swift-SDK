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
import SwiftyJSON


// URL constants
let HOST = "https://api.knurld.io"
let BASE_PATH = "/v1"
let API_URL = HOST + BASE_PATH

// String constants
let DEVELOPER_ID_PARAM_NAME = "Developer-Id"
let AUTHORIZATION_PARAM_NAME = "Authorization"


public class KnurldV1API {
    private let requestManager: HTTPRequestManager
    
    public init() {
        self.requestManager = HTTPRequestManager()
    }
    
    private func makeAuthHeaders(developerID developerID: String, authorization: String) -> [String : String] {
        return [DEVELOPER_ID_PARAM_NAME: developerID, AUTHORIZATION_PARAM_NAME: "Bearer \(authorization)"]
    }
    
    /// POST /oauth/...
    public func authorize(clientID clientID: String, clientSecret: String, successHandler: (accessToken: String) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = HOST + "/oauth/client_credential/accesstoken?grant_type=client_credentials"
        let body = ["client_id": clientID, "client_secret": clientSecret]
        
        requestManager.postForm(url: url, headers: nil, body: body,
                                successHandler: { json in
                                    print("JSON: \(json)")
                                    guard let accessToken = json["access_token"].string else {
                                        failureHandler(error: .ResponseInvalid)
                                        return
                                    }
                                    successHandler(accessToken: accessToken) },
                                failureHandler: { error in failureHandler(error: error) })
    }
    
    /// GET /status
    public func getServiceStatus(developerID developerID: String, authorization: String, successHandler: (href: String, name: String, version: String) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = API_URL + "/status"
        let headers = makeAuthHeaders(developerID: developerID, authorization: authorization)
        
        requestManager.get(url: url, headers: headers,
                           successHandler: { json in
                                guard let href = json["href"].string, let name = json["name"].string, let version = json["version"].string else {
                                    failureHandler(error: .ResponseInvalid)
                                    return
                                }
                                successHandler(href: href, name: name, version: version) },
                           failureHandler: { error in failureHandler(error: error) })
    }
}











protocol JSONRepresentable {
    func toJsonDictionary() -> [String: AnyObject]
    //init?(json: JSON)
}

public struct AppModelParams: JSONRepresentable {
    let enrollmentRepeats: Int
    let vocabulary: [String]
    let verificationLength: Int
    let threshold: Float? = nil
    let autoThresholdEnable: Bool? = nil
    let autoThresholdClearance: Int? = nil
    let autoThresholdMaxRise: Int? = nil
    let useModelUpdate: Bool? = nil
    let modelUpdateDailyLimit: Int? = nil
    
    public init(enrollmentRepeats: Int, vocabulary: [String], verificationLength: Int) {
        self.enrollmentRepeats = enrollmentRepeats
        self.vocabulary = vocabulary
        self.verificationLength = verificationLength
    }
    
    func toJsonDictionary() -> [String : AnyObject] {
        var dict: [String : AnyObject] = ["enrollmentRepeats": self.enrollmentRepeats,
                                          "vocabulary": self.vocabulary,
                                          "verificationLength": self.verificationLength]
        
        if let threshold = self.threshold {
            dict["threshold"] = threshold
        }
        if let autoThresholdEnable = self.autoThresholdEnable {
            dict["autoThresholdEnable"] = autoThresholdEnable
        }
        if let autoThresholdClearance = self.autoThresholdClearance {
            dict["autoThresholdClearance"] = autoThresholdClearance
        }
        if let autoThresholdMaxRise = self.autoThresholdMaxRise {
            dict["autoThresholdMaxRise"] = autoThresholdMaxRise
        }
        if let useModelUpdate = self.useModelUpdate {
            dict["useModelUpdate"] = useModelUpdate
        }
        if let modelUpdateDailyLimit = self.modelUpdateDailyLimit {
            dict["modelUpdateDailyLimit"] = modelUpdateDailyLimit
        }
        
        return dict
    }
    
    /*
    init?(json: JSON) {
        // Make sure we have all mandatory parameters
        guard let er = json["enrollmentRepeats"].int,
            let vocJSON = json["vocabulary"].array,
            let vl = json["verificationLength"].string else //@todo dangerouselse
        {
            return nil
        }
        
        self.enrollmentRepeats = er
        
    }
     */
}

/*
public func createAppModel(developerID developerID: String, authorization: String, params: AppModelParams, onSuccess: (href: String) -> Void, onFailure: (error: Error) -> Void)
{
    let url = API_URL + "/app-models"
    
    let headers = [DEVELOPER_ID_PARAM_NAME: developerID, AUTHORIZATION_PARAM_NAME: "Bearer \(authorization)"]
    let parameters = params.toJsonDictionary()
    
    Alamofire.request(.POST, url, headers: headers, parameters: parameters, encoding: .JSON).validate().responseJSON() { response in
        switch response.result {
        case .Success:
            if let value = response.result.value {
                let json = JSON(value)
                
                if let href = json["href"].string {
                    onSuccess(href: href)
                    return
                }
            }
        case .Failure(let error):
            onFailure(error: .Internal)
            return
        }
        
        onFailure(error: .Internal)
    }
}
*/