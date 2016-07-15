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


struct URLEndpointAnalysisCreateRequest: JSONEncodable {
    let audioURL: String
    let numWords: Int
    
    func toJSON() -> JSON {
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

struct EndpointAnalysisInterval: JSONDecodable {
    let start: Int
    let stop: Int
    
    init(json: JSON) throws {
        self.start = try json.int(EndpointAnalysisConstants.startParam)
        self.stop = try json.int(EndpointAnalysisConstants.stopParam)
    }
}

struct EndpointAnalysis: JSONDecodable {
    let taskName: String
    let taskStatus: String
    let intervals: [EndpointAnalysisInterval]
    
    init(json: JSON) throws {
        self.taskName = try json.string(EndpointAnalysisConstants.taskNameParam)
        self.taskStatus = try json.string(EndpointAnalysisConstants.taskStatusParam)
        self.intervals = try json.array(EndpointAnalysisConstants.intervalsParam).map(EndpointAnalysisInterval.init)
    }
}

struct EndpointAnalysisEndpoint: SupportsJSONGets {
    typealias GetHeadersType = KnurldCredentials
    typealias GetResponseType = EndpointAnalysis
    
    let url: String
    
    init(summary: EndpointAnalysisSummary) {
        self.url = EndpointCommons.DEFAULT_URL + "/endpointAnalysis/\(summary.taskName)"
    }
}

struct URLEndpointAnalysisEndpoint: SupportsJSONPosts {
    typealias PostHeadersType = KnurldCredentials
    typealias PostRequestType = URLEndpointAnalysisCreateRequest
    typealias PostResponseType = EndpointAnalysisSummary
    
    let url: String
}