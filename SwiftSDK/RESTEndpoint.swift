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
    var requestManager: HTTPRequestManager { get }
    var url: String { get }
}

protocol SupportsPosts: IsAPIEndpoint {
    associatedtype HeadersType
    associatedtype PostRequestType
    associatedtype PostResponseType
    
    func post(headers headers: HeadersType,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
}

protocol SupportsHeaderlessStringMapPosts: SupportsPosts {
    associatedtype HeadersType = Void
    associatedtype PostRequestType: StringMapRepresentable
    associatedtype PostResponseType: JSONDecodable
    
    func post(headers headers: Void,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
}

protocol SupportsJSONPosts: SupportsPosts {
    associatedtype HeadersType: StringMapRepresentable
    associatedtype PostRequestType: JSONEncodable
    associatedtype PostResponseType: JSONDecodable
    
    func post(headers headers: HeadersType,
                      body: PostRequestType,
                      successHandler: (response: PostResponseType) -> Void,
                      failureHandler: (error: HTTPRequestError) -> Void)
}

extension SupportsHeaderlessStringMapPosts {
    func postHelper(body body: PostRequestType,
                         successHandler: (response: PostResponseType) -> Void,
                         failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let body = body.toStringMap()
        
        self.requestManager.postForm(url: url, headers: nil, body: body,
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
    func post(headers headers: HeadersType,
                            body: PostRequestType,
                            successHandler: (response: PostResponseType) -> Void,
                            failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let headers = headers.toStringMap()
        let body = body.toJSON()
        
        self.requestManager.postJSON(url: url, headers: headers, body: body,
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


class EndpointCRUDFamily<Creator: SupportsJSONPosts> {
    let creator: Creator
    
    init(creator: Creator) {
        self.creator = creator
    }
    
    func create(headers headers: Creator.HeadersType,
                        request: Creator.PostRequestType,
                        successHandler: (response: Creator.PostResponseType) -> Void,
                        failureHandler: (error: HTTPRequestError) -> Void)
    {
        self.creator.post(credentials: credentials, request: request, successHandler: successHandler, failureHandler: failureHandler)
    }
}



/// A class of REST endpoints that combined implement CRUD operations for a single data type
class RESTEndpointFamily<ResourceType: protocol<KnurldResource, JSONDecodable>, ResourcePageType: JSONDecodable, ResourceCreateRequestType: JSONEncodable, ResourceUpdateRequestType: JSONEncodable>
{
    let url: String
    let requestManager: HTTPRequestManager
    
    init(url: String, requestManager: HTTPRequestManager) {
        self.url = url
        self.requestManager = requestManager
    }
    
    func create(credentials credentials: KnurldCredentials,
                            request: ResourceCreateRequestType,
                            successHandler: (locator: ResourceLocator<ResourceType>) -> Void,
                            failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let headers = credentials.toStringMap()
        let body = request.toJSON()
        
        print("CREATE (POST): URL: \(url) headers: \(headers) body: \(body)")
        
        requestManager.postJSON(url: url, headers: headers, body: body,
                                successHandler: { json in
                                    do {
                                        let locator = try ResourceLocator<ResourceType>(json: json)
                                        successHandler(locator: locator)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                                        return
                                    }
            },
                                failureHandler: { error in failureHandler(error: error) })
    }
    
    func get(credentials credentials: KnurldCredentials,
                         locator: ResourceLocator<ResourceType>,
                         successHandler: (resource: ResourceType) -> Void,
                         failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = locator.getURL()
        let headers = credentials.toStringMap()
        
        print("GET: URL: \(url) headers: \(headers)")
        
        self.requestManager.get(url: url,
                                headers: headers,
                                successHandler: { json in
                                    do {
                                        let resource = try ResourceType(json: json)
                                        successHandler(resource: resource)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                                        return
                                    }
            },
                                failureHandler: { error in failureHandler(error: error) })
    }
    
    func update(credentials credentials: KnurldCredentials,
                            locator: ResourceLocator<ResourceType>,
                            request: ResourceUpdateRequestType,
                            successHandler: (locator: ResourceLocator<ResourceType>) -> Void,
                            failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = locator.getURL()
        let headers = credentials.toStringMap()
        let body = request.toJSON()
        
        print("UPDATE: URL: \(url) headers: \(headers) body: \(body)")
        
        requestManager.postJSON(url: url, headers: headers, body: body,
                                successHandler: { json in
                                    do {
                                        let locator = try ResourceLocator<ResourceType>(json: json)
                                        successHandler(locator: locator)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                                    }
            },
                                failureHandler: { error in failureHandler(error: error) })
    }
    
    func delete(credentials credentials: KnurldCredentials,
                            locator: ResourceLocator<ResourceType>,
                            successHandler: () -> Void,
                            failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = locator.getURL()
        let headers = credentials.toStringMap()
        
        print("DELETE: URL: \(url) headers: \(headers)")
        
        requestManager.delete(url: url, headers: headers, successHandler: successHandler, failureHandler: failureHandler)
    }
    
    func getPage(credentials credentials: KnurldCredentials,
                             successHandler: (page: ResourcePageType) -> Void,
                             failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let headers = credentials.toStringMap()
        
        print("GET page: URL: \(url) headers: \(headers)")
        
        requestManager.get(url: url, headers: headers,
                           successHandler: { json in
                            do {
                                let page = try ResourcePageType(json: json)
                                successHandler(page: page)
                                return
                            } catch  {
                                failureHandler(error: .ResponseDeserializationError(error: error as? JSON.Error))
                                return
                            }
                            },
                           failureHandler: { error in failureHandler(error: error) })
    }
}