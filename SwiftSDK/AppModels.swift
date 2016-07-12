//
//  AppModels.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/11/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


/// A Knurld application model
struct AppModel: JSONEncodable, JSONDecodable {
    // Mandatory fields
    var enrollmentRepeats: Int
    let vocabulary: [String]
    var verificationLength: Int
    
    // Optional fields
    var threshold: Double?
    let autoThresholdEnable: Bool?
    let autoThresholdClearance: Int?
    let autoThresholdMaxRise: Int?
    let useModelUpdate: Bool?
    let modelUpdateDailyLimit: Int?
    
    let locator: AppModelLocator?
    
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
        
        self.locator = nil
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
        
        self.locator = try json.decode("", alongPath: [.MissingKeyBecomesNil, .NullBecomesNil])
    }
    
    func toJSON() -> JSON {
        var json: [String : JSON] = [
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
    
    func updatableParameters() -> JSON {
        var json: [String : JSON] = [
            "enrollmentRepeats": .Int(self.enrollmentRepeats),
            "verificationLength": .Int(self.verificationLength)]
        
        if let threshold = self.threshold {
            json.updateValue(JSON.Double(threshold), forKey: "threshold")
        }
        
        return .Dictionary(json)
    }
}


/// A Knurld application model identifier
typealias AppModelID = String

protocol AppModelLocating {
    func appModelLocation() -> AppModelLocator
}

extension AppModelID: AppModelLocating {
    func appModelLocation() -> AppModelLocator {
        return AppModelLocator(href: KnurldV1API.API_URL + "/app-models/\(self)")
    }
}

/// A locator of a Knurld app model
struct AppModelLocator: JSONDecodable, AppModelLocating {
    let href: String
    
    init(json: JSON) throws {
        self.href = try json.string("href")
    }
    
    init(href: String) {
        self.href = href
    }
    
    func appModelLocation() -> AppModelLocator {
        return self
    }
}


extension KnurldV1API {
    /// Create a new app model (POST /app-models)
    func createAppModel(credentials credentials: KnurldCredentials, model: AppModel, successHandler: (locator: AppModelLocator) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = KnurldV1API.API_URL + "/app-models"
        let headers = credentials.toStringMap()
        let parameters = model.toJSON()
        
        requestManager.postJSON(url: url, headers: headers, body: parameters,
                                successHandler: { json in
                                    do {
                                        let locator = try AppModelLocator(json:json)
                                        successHandler(locator: locator)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError)
                                        return
                                    }
            },
                                failureHandler: { error in failureHandler(error: error) })
    }
    
    /// Get "all" application models (GET /app-models)
    func getAppModels(credentials credentials: KnurldCredentials, successHandler: (models: [AppModel]) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = KnurldV1API.API_URL + "/app-models"
        let headers = credentials.toStringMap()
        
        requestManager.get(url: url, headers: headers,
                           successHandler: { json in
                            print("GET /app-models: Raw JSON: \(json)")
                            do {
                                let appModels = try json.array("items").map(AppModel.init)
                                successHandler(models: appModels)
                                return
                            } catch {
                                failureHandler(error: .ResponseDeserializationError)
                                return
                            }
            },
                           failureHandler: { error in failureHandler(error: error) })
    }
    
    /// Get a specific app model (GET /app-models/{id})
    func getAppModel(credentials credentials: KnurldCredentials, locator: AppModelLocating, successHandler: (model: AppModel) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = locator.appModelLocation().href
        let headers = credentials.toStringMap()
        
        requestManager.get(url: url,
                           headers: headers,
                           successHandler: { json in
                            do {
                                let appModel = try AppModel(json: json)
                                successHandler(model: appModel)
                                return
                            } catch {
                                failureHandler(error: .ResponseDeserializationError)
                                return
                            }
            },
                           failureHandler: { error in failureHandler(error: error) })
    }
    
    
    /// Update a specific app model, as far as the API will allow (UPDATE /app-models/{id})
    func updateAppModel(credentials credentials: KnurldCredentials, locator: AppModelLocating, model: AppModel, successHandler: (model: AppModel) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = locator.appModelLocation().href
        let headers = credentials.toStringMap()
        let body = model.updatableParameters()
        
        print("RAW: URL: \(url) headers: \(headers) body: \(body)")
        
        requestManager.postJSON(url: url, headers: headers, body: body,
                                  successHandler: { json in
                                    print("Update app model: Raw response JSON: \(json)")
                                    do {
                                        let appModel = try AppModel(json: json)
                                        successHandler(model: appModel)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError)
                                    }
                                   },
                                   failureHandler: { error in failureHandler(error: error) })
    }
    
    func deleteAppModel(credentials credentials: KnurldCredentials, locator: AppModelLocating, successHandler: (Void) -> Void, failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = locator.appModelLocation().href
        let headers = credentials.toStringMap()
        
        print("Delete app model: URL: \(url) headers: \(headers)")
        
        requestManager.delete(url: url, headers: headers, successHandler: successHandler, failureHandler: failureHandler)
    }
}