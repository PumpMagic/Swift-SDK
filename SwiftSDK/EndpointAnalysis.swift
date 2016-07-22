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
    
    static let audioFileParam = "filename"
}


/// All parameters involved in requesting the analysis of an audio file given its URL.
public struct URLEndpointAnalysisCreateRequest: JSONEncodable {
    public let audioURL: String
    public let numWords: Int
    
    /// Initialize a request.
    public init(audioURL: String, numWords: Int) {
        self.audioURL = audioURL
        self.numWords = numWords
    }
    
    /// Convert to JSON.
    public func toJSON() -> JSON {
        return .Dictionary([
            EndpointAnalysisConstants.audioURLParam: .String(self.audioURL),
            EndpointAnalysisConstants.numWordsParam: .Int(self.numWords)])
    }
}

/// All parameters involved in requesting the analysis of an audio file given its contents.
public struct FileEndpointAnalysisCreateRequest: MultipartRepresentable {
    public let audioFile: NSData
    public let numWords: Int?
    
    /// Initialize a request.
    public init(audioFile: NSData, numWords: Int?) {
        self.audioFile = audioFile
        self.numWords = numWords
    }
    
    //@todo use num_words... doesn't do anything for now
    func toMultipart() -> [String : (String, NSData)] {
        return [EndpointAnalysisConstants.audioFileParam: ("audio/wav", self.audioFile)]
            //,EndpointAnalysisConstants.numWordsParam: self.numWords]
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

/// A period of time during which human voice was detected.
public struct EndpointAnalysisInterval: JSONDecodable {
    public let start: Int
    public let stop: Int
    
    /// Convert to JSON.
    public init(json: JSON) throws {
        self.start = try json.int(EndpointAnalysisConstants.startParam)
        self.stop = try json.int(EndpointAnalysisConstants.stopParam)
    }
}

/// An endpoint analysis.
public struct EndpointAnalysis: JSONDecodable {
    public let taskName: String
    public let taskStatus: String
    public let intervals: [EndpointAnalysisInterval]
    
    /// Convert to JSON.
    public init(json: JSON) throws {
        self.taskName = try json.string(EndpointAnalysisConstants.taskNameParam)
        self.taskStatus = try json.string(EndpointAnalysisConstants.taskStatusParam)
        self.intervals = try json.array(EndpointAnalysisConstants.intervalsParam).map(EndpointAnalysisInterval.init)
    }
}

/// An endpoint analysis API endpoint.
public struct EndpointAnalysisEndpoint: SupportsJSONGets {
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = EndpointAnalysis
    
    public let url: String
    
    init(summary: EndpointAnalysisSummary, analysisEndpointURL: String) {
        self.url = analysisEndpointURL + "/\(summary.taskName)"
    }
}

struct URLEndpointAnalysisEndpoint: SupportsJSONPosts {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = URLEndpointAnalysisCreateRequest
    typealias PostResponseType = EndpointAnalysisSummary
    
    let url: String
}

struct FileEndpointAnalysisEndpoint: SupportsMultipartPosts {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = FileEndpointAnalysisCreateRequest
    typealias PostResponseType = EndpointAnalysisSummary
    
    let url: String
}