//
//  KnurldV1API.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/6/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON


let HOST = "https://api.knurld.io"
let BASE_PATH = "/v1"
let API_URL = HOST + BASE_PATH

let DEVELOPER_ID_PARAM_NAME = "Developer-Id"
let AUTHORIZATION_PARAM_NAME = "Authorization"

public enum Error {
    case AlamofireReturned
    case Other
}

public func authorize(clientID clientID: String, clientSecret: String, onSuccess: (accessToken: String) -> Void, onFailure: (error: Error) -> Void) {
    let url = HOST + "/oauth/client_credential/accesstoken?grant_type=client_credentials"
    
    let parameters = ["client_id": clientID, "client_secret": clientSecret]
    
    Alamofire.request(.POST, url, parameters: parameters, encoding: .URL).validate().responseJSON() { response in
        switch response.result {
        case .Success:
            if let value = response.result.value {
                let json = JSON(value)
                print("JSON: \(json)")
                
                if let accessToken = json["access_token"].string {
                    onSuccess(accessToken: accessToken)
                    return
                }
            }
        case .Failure(let error):
            print("Error: \(error)")
            
            onFailure(error: .AlamofireReturned)
            return
        }
        
        onFailure(error: .Other)
    }
}

/*
 func status(developerID: String, authorization: String, onSuccess: (href: String, name: String, version: String) -> Void, onFailure: (error: Error) -> Void) {
 let url = API_URL + "/status"
 
 let headers = [DEVELOPER_ID_PARAM_NAME: developerID, AUTHORIZATION_PARAM_NAME: "Bearer \(authorization)"]
 
 Alamofire.request(.POST, url, headers: headers)
 }
 */

/*
 func endpointFile(fileData: NSData, numWords: String) {
 let url = API_PATH + "/endpointAnalysis/file"
 
 let headers = [
 "Developer-Id:": developerID,
 "Authorization": token
 ]
 
 func formDataConstructor(multipartFormData: Alamofire.MultipartFormData) {
 multipartFormData.appendBodyPart(data: fileData, name: "filedata")
 
 if let numWordsNSData = numWords.dataUsingEncoding(NSUTF8StringEncoding) {
 multipartFormData.appendBodyPart(data: numWordsNSData, name: "words")
 } else {
 print("Unable to represent number of words as NSData")
 }
 }
 
 func completionHandler(result: Alamofire.Manager.MultipartFormDataEncodingResult) {
 switch result {
 case .Success(let upload, _, _):
 print("Success!")
 upload.responseJSON { response in
 debugPrint(response)
 }
 case .Failure(let encodingError):
 print("Failure!")
 print(encodingError)
 }
 }
 
 Alamofire.upload(.POST, url, headers: headers, multipartFormData: formDataConstructor, encodingCompletion: completionHandler)
 }
 */