//
//  AppModels.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/11/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


/// Constants associated with app models - just parameter names
private struct AppModelConstants {
    static let enrollmentRepeatsParam = "enrollmentRepeats"
    static let vocabularyParam = "vocabulary"
    static let verificationLengthParam = "verificationLength"
    static let thresholdParam = "threshold"
    static let autoThresholdEnableParam = "autoThresholdEnable"
    static let autoThresholdClearanceParam = "autoThresholdClearance"
    static let autoThresholdMaxRiseParam = "autoThresholdMaxRise"
    static let useModelUpdateParam = "useModelUpdate"
    static let modelUpdateDailyLimitParam = "modelUpdateDailyLimit"
    static let limitParam = "limit"
    static let nextParam = "next"
    static let itemsParam = "items"
    static let prevParam = "prev"
    static let totalParam = "total"
    static let hrefParam = "href"
    static let offsetParam = "offset"
}

/// All parameters involved in requesting a Knurld application model ("app model").
/// For further information on all relevant properties, please see the Knurld Developer Guide.
public struct AppModelCreateRequest: JSONEncodable {
    // Mandatory fields
    public let enrollmentRepeats: Int
    public let vocabulary: [String]
    public let verificationLength: Int
    
    // Optional fields
    public let threshold: Double?
    public let autoThresholdEnable: Bool?
    public let autoThresholdClearance: Int?
    public let autoThresholdMaxRise: Int?
    public let useModelUpdate: Bool?
    public let modelUpdateDailyLimit: Int?
    
    /// Initialize a request, not specifying any optional parameters
    public init(enrollmentRepeats: Int, vocabulary: [String], verificationLength: Int) {
        self.init(enrollmentRepeats: enrollmentRepeats, vocabulary: vocabulary, verificationLength: verificationLength, threshold: nil,
                  autoThresholdEnable: nil, autoThresholdClearance: nil, autoThresholdMaxRise: nil, useModelUpdate: nil, modelUpdateDailyLimit: nil)
    }
    
    /// Initialize a request, specifying optional parameters
    public init(enrollmentRepeats: Int, vocabulary: [String], verificationLength: Int, threshold: Double?, autoThresholdEnable: Bool?,
                autoThresholdClearance: Int?, autoThresholdMaxRise: Int?, useModelUpdate: Bool?, modelUpdateDailyLimit: Int?)
    {
        self.enrollmentRepeats = enrollmentRepeats
        self.vocabulary = vocabulary
        self.verificationLength = verificationLength
        
        self.threshold = threshold
        self.autoThresholdEnable = autoThresholdEnable
        self.autoThresholdClearance = autoThresholdClearance
        self.autoThresholdMaxRise = autoThresholdMaxRise
        self.useModelUpdate = useModelUpdate
        self.modelUpdateDailyLimit = modelUpdateDailyLimit
    }
    
    /// Convert this type into JSON (for internal use only)
    public func toJSON() -> JSON {
        var json: [String : JSON] = [
            AppModelConstants.enrollmentRepeatsParam: .Int(self.enrollmentRepeats),
            AppModelConstants.vocabularyParam: .Array(self.vocabulary.map(JSON.String)),
            AppModelConstants.verificationLengthParam: .Int(self.verificationLength)]
        
        if let threshold = self.threshold {
            json.updateValue(JSON.Double(threshold), forKey: AppModelConstants.thresholdParam)
        }
        if let autoThresholdEnable = self.autoThresholdEnable {
            json.updateValue(JSON.Bool(autoThresholdEnable), forKey: AppModelConstants.autoThresholdEnableParam)
        }
        if let autoThresholdClearance = self.autoThresholdClearance {
            json.updateValue(JSON.Int(autoThresholdClearance), forKey: AppModelConstants.autoThresholdClearanceParam)
        }
        if let autoThresholdMaxRise = self.autoThresholdMaxRise {
            json.updateValue(JSON.Int(autoThresholdMaxRise), forKey: AppModelConstants.autoThresholdMaxRiseParam)
        }
        if let useModelUpdate = self.useModelUpdate {
            json.updateValue(JSON.Bool(useModelUpdate), forKey: AppModelConstants.useModelUpdateParam)
        }
        if let modelUpdateDailyLimit = self.modelUpdateDailyLimit {
            json.updateValue(JSON.Int(modelUpdateDailyLimit), forKey: AppModelConstants.modelUpdateDailyLimitParam)
        }
        
        return .Dictionary(json)
    }
}

/// All parameters needed to create a Knurld application model update request
public struct AppModelUpdateRequest: JSONEncodable {
    public let enrollmentRepeats: Int?
    public let threshold: Double?
    public let verificationLength: Int?
    
    public init(enrollmentRepeats: Int?, threshold: Double?, verificationLength: Int?) {
        self.enrollmentRepeats = enrollmentRepeats
        self.threshold = threshold
        self.verificationLength = verificationLength
    }
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        var json: [String : JSON] = [:]
        
        if let enrollmentRepeats = self.enrollmentRepeats {
            json.updateValue(.Int(enrollmentRepeats), forKey: AppModelConstants.enrollmentRepeatsParam)
        }
        if let threshold = self.threshold {
            json.updateValue(.Double(threshold), forKey: AppModelConstants.thresholdParam)
        }
        if let verificationLength = self.verificationLength {
            json.updateValue(.Int(verificationLength), forKey: AppModelConstants.verificationLengthParam)
        }
        
        return .Dictionary(json)
    }
}

/// A Knurld application model
public struct AppModel: JSONEncodable, JSONDecodable {
    public let enrollmentRepeats: Int
    public let vocabulary: [String]
    public let verificationLength: Int
    public let threshold: Double
    public let autoThresholdEnable: Bool
    public let autoThresholdClearance: Int
    public let autoThresholdMaxRise: Int
    public let useModelUpdate: Bool
    public let modelUpdateDailyLimit: Int
    public let href: String
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.enrollmentRepeats = try json.int(AppModelConstants.enrollmentRepeatsParam)
        self.vocabulary = try json.array(AppModelConstants.vocabularyParam).map(String.init)
        self.verificationLength = try json.int(AppModelConstants.verificationLengthParam)
        self.threshold = try json.double(AppModelConstants.thresholdParam)
        self.autoThresholdEnable = try json.bool(AppModelConstants.autoThresholdEnableParam)
        self.autoThresholdClearance = try json.int(AppModelConstants.autoThresholdClearanceParam)
        self.autoThresholdMaxRise = try json.int(AppModelConstants.autoThresholdMaxRiseParam)
        self.useModelUpdate = try json.bool(AppModelConstants.useModelUpdateParam)
        self.modelUpdateDailyLimit = try json.int(AppModelConstants.modelUpdateDailyLimitParam)
        self.href = try json.string(AppModelConstants.hrefParam)
    }
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            AppModelConstants.enrollmentRepeatsParam: .Int(self.enrollmentRepeats),
            AppModelConstants.vocabularyParam: .Array(self.vocabulary.map(JSON.String)),
            AppModelConstants.verificationLengthParam: .Int(self.verificationLength),
            AppModelConstants.thresholdParam: .Double(self.threshold),
            AppModelConstants.autoThresholdEnableParam: .Bool(self.autoThresholdEnable),
            AppModelConstants.autoThresholdClearanceParam: .Int(self.autoThresholdClearance),
            AppModelConstants.autoThresholdMaxRiseParam: .Int(self.autoThresholdMaxRise),
            AppModelConstants.useModelUpdateParam: .Bool(self.useModelUpdate),
            AppModelConstants.modelUpdateDailyLimitParam: .Int(self.modelUpdateDailyLimit)])
    }
}

/// A subset of an application's app models with metadata and information on where the rest are
public struct AppModelPage: JSONDecodable {
    public let limit: Int
    public let next: WebAddress?
    public let items: [AppModel]
    public let prev: WebAddress?
    public let total: Int
    public let href: WebAddress
    public let offset: Int
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.limit = try json.int(AppModelConstants.limitParam)
        self.next = try json.string(AppModelConstants.nextParam, alongPath: [.NullBecomesNil])
        self.items = try json.array(AppModelConstants.itemsParam).map(AppModel.init)
        self.prev = try json.string(AppModelConstants.prevParam, alongPath: [.NullBecomesNil])
        self.total = try json.int(AppModelConstants.totalParam)
        self.href = try json.string(AppModelConstants.hrefParam)
        self.offset = try json.int(AppModelConstants.offsetParam)
    }
}

/// /app-models
struct AppModelsEndpoint: SupportsJSONPosts, SupportsJSONGets {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = AppModelCreateRequest
    typealias PostResponseType = AppModelEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = AppModelPage
    
    let url: String
}


public struct AppModelEndpoint: JSONDecodable, SupportsJSONPosts, SupportsJSONGets, SupportsDeletes {
    // ( /app-models/{id} )
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = AppModelUpdateRequest
    typealias PostResponseType = AppModelEndpoint
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = AppModel
    typealias DeleteHeadersType = KnurldCredentials
    
    let url: String
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.url = try json.string(AppModelConstants.hrefParam)
    }
}
