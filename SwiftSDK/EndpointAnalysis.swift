//
//  EndpointAnalysis.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/15/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


private struct EndpointAnalysisConstants {
    static let audioURLParam = "audioUrl"
    static let numWordsParam = "num_words"
    static let taskNameParam = "taskName"
    static let taskStatusParam = "taskStatus"
    
    static let intervalsParam = "intervals"
    static let startParam = "start"
    static let stopParam = "stop"
}


public struct URLEndpointAnalysisCreateRequest: JSONEncodable {
    let audioURL: String
    let numWords: Int
    
    public init(audioURL: String, numWords: Int) {
        self.audioURL = audioURL
        self.numWords = numWords
    }
    
    /// This function is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public func toJSON() -> JSON {
        return .Dictionary([
            EndpointAnalysisConstants.audioURLParam: .String(self.audioURL),
            EndpointAnalysisConstants.numWordsParam: .Int(self.numWords)])
    }
}


struct EndpointAnalysisSummary: JSONDecodable {
    let taskName: String
    let taskStatus: String
    
    init(json: JSON) throws {
        self.taskName = try json.string(EndpointAnalysisConstants.taskNameParam)
        self.taskStatus = try json.string(EndpointAnalysisConstants.taskStatusParam)
    }
}

public struct EndpointAnalysisInterval: JSONDecodable {
    public let start: Int
    public let stop: Int
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.start = try json.int(EndpointAnalysisConstants.startParam)
        self.stop = try json.int(EndpointAnalysisConstants.stopParam)
    }
}

public struct EndpointAnalysis: JSONDecodable {
    public let taskName: String
    public let taskStatus: String
    public let intervals: [EndpointAnalysisInterval]
    
    /// This initializer is only public because Swift protocol conformance of public protocols cannot be internal.
    /// Please don't use it!
    public init(json: JSON) throws {
        self.taskName = try json.string(EndpointAnalysisConstants.taskNameParam)
        self.taskStatus = try json.string(EndpointAnalysisConstants.taskStatusParam)
        self.intervals = try json.array(EndpointAnalysisConstants.intervalsParam).map(EndpointAnalysisInterval.init)
    }
}

public struct EndpointAnalysisEndpoint: SupportsJSONGets {
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = EndpointAnalysis
    
    let url: String
    
    init(summary: EndpointAnalysisSummary) {
        //@todo delegate the base to whatever was passed to KnurldAPI
        self.url = EndpointCommons.DEFAULT_URL + "/endpointAnalysis/\(summary.taskName)"
    }
}

struct URLEndpointAnalysisEndpoint: SupportsJSONPosts {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = URLEndpointAnalysisCreateRequest
    typealias PostResponseType = EndpointAnalysisSummary
    
    let url: String
}