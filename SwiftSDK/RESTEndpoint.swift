//
//  RESTEndpointFamily.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/13/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


protocol IsAPIEndpoint {
    var url: String { get }
}

/// StringMapRepresentable captures items that can be represented as string:string maps
/// This is for use with API endpoints that work with form bodies instead of JSON bodies
protocol StringMapRepresentable {
    func toStringMap() -> [String : String]
}

protocol StringNSDataDictionaryRepresentable {
    func toStringNSDataDictionary() -> [String : NSData]
}


/** Begin POST methods */

protocol SupportsPosts: IsAPIEndpoint {
    associatedtype PostHeadersType
    associatedtype PostRequestType
    associatedtype PostResponseType
    
    func post(manager manager: HTTPRequestManager,
                      headers: PostHeadersType,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
}

protocol SupportsHeaderlessStringMapPosts: SupportsPosts {
    associatedtype PostHeadersType = Void
    associatedtype PostRequestType: StringMapRepresentable
    associatedtype PostResponseType: JSONDecodable
    
    func post(manager manager: HTTPRequestManager,
                      headers: Void,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
}

/*
protocol SupportsEmptyPosts: SupportsPosts {
    associatedtype PostHeadersType: StringMapRepresentable
    associatedtype PostRequestType = Void
    associatedtype PostResponseType: JSONDecodable
    
    func post(manager manager: HTTPRequestManager,
                      headers: PostHeadersType,
                      body: Void,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
}
*/
 
protocol SupportsJSONPosts: SupportsPosts {
    associatedtype PostHeadersType: StringMapRepresentable
    associatedtype PostRequestType: JSONEncodable
    associatedtype PostResponseType: JSONDecodable
    
    func post(manager manager: HTTPRequestManager,
                      headers: PostHeadersType,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
}

protocol SupportsMultipartPosts: SupportsPosts {
    associatedtype PostHeadersType: StringMapRepresentable
    associatedtype PostRequestType: StringNSDataDictionaryRepresentable
    associatedtype PostResponseType: JSONDecodable
    
    func post(manager manager: HTTPRequestManager,
                      headers: PostHeadersType,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
}

extension SupportsHeaderlessStringMapPosts {
    func post(manager manager: HTTPRequestManager,
                      headers: PostHeadersType,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let body = body.toStringMap()
        
        manager.postForm(url: url, headers: nil, body: body,
                                          successHandler: { json in
                                            do {
                                                let authorizationResponse = try PostResponseType(json: json)
                                                successHandler(response: authorizationResponse)
                                                return
                                            } catch {
                                                failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                                                return
                                            }
            },
                                          failureHandler: { error in failureHandler(error: error) })
    }
}

extension SupportsJSONPosts {
    func post(manager manager: HTTPRequestManager,
                      headers: PostHeadersType,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let headers = headers.toStringMap()
        let body = body.toJSON()
        
        manager.postJSON(url: url, headers: headers, body: body,
                                          successHandler: { json in
                                            do {
                                                let authorizationResponse = try PostResponseType(json: json)
                                                successHandler(response: authorizationResponse)
                                                return
                                            } catch {
                                                failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                                                return
                                            }
            },
                                          failureHandler: { error in failureHandler(error: error) })
    }
}

extension SupportsMultipartPosts {
    func post(manager manager: HTTPRequestManager,
                      headers: PostHeadersType,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let headers = headers.toStringMap()
        let body = body.toStringNSDataDictionary()
        
        manager.postMultipart(url: url,
                              headers: headers,
                              bodies: body,
                              successHandler: { json in
                                do {
                                    let authorizationResponse = try PostResponseType(json: json)
                                    successHandler(response: authorizationResponse)
                                    return
                                } catch {
                                    failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                                    return
                                }
                              },
                              failureHandler: { error in failureHandler(error: error) })
    }
}

/** End POST methods */


/** Begin GET methods */

protocol SupportsGets: IsAPIEndpoint {
    associatedtype GetHeadersType
    associatedtype GetResponseType
    
    func get(manager manager: HTTPRequestManager,
                     headers: GetHeadersType,
                     successHandler: (response: GetResponseType) -> Void,
                     failureHandler: (error: HTTPRequestError) -> Void)
}

protocol SupportsJSONGets: SupportsGets {
    associatedtype GetHeadersType: StringMapRepresentable
    associatedtype GetResponseType: JSONDecodable
    
    func get(manager manager: HTTPRequestManager,
                     headers: GetHeadersType,
                     successHandler: (response: GetResponseType) -> Void,
                     failureHandler: (error: HTTPRequestError) -> Void)
}

extension SupportsJSONGets {
    func get(manager manager: HTTPRequestManager,
                     headers: GetHeadersType,
                     successHandler: (response: GetResponseType) -> Void,
                     failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let headers = headers.toStringMap()
        
        manager.get(url: url, headers: headers,
                    successHandler: { json in
                        do {
                            let authorizationResponse = try GetResponseType(json: json)
                            successHandler(response: authorizationResponse)
                            return
                        } catch {
                            failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                            return
                        }
            },
                    failureHandler: { error in failureHandler(error: error) })
    }
}

/** End GET methods */

/** Begin DELETE methods */

protocol SupportsDeletes: IsAPIEndpoint {
    associatedtype DeleteHeadersType: StringMapRepresentable
    
    func delete(manager manager: HTTPRequestManager,
                        headers: DeleteHeadersType,
                        successHandler: () -> Void,
                        failureHandler: (error: HTTPRequestError) -> Void)
}

extension SupportsDeletes {
    func delete(manager manager: HTTPRequestManager,
                        headers: DeleteHeadersType,
                        successHandler: () -> Void,
                        failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let headers = headers.toStringMap()
        
        manager.delete(url: url, headers: headers,
                       successHandler: successHandler,
                       failureHandler: { error in failureHandler(error: error) })
    }
}

/** End DELETE methods */
