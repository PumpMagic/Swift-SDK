//
//  RESTEndpointFamily.swift
//  SwiftSDK
//
//  Created by Ryan Conway on 7/13/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


/// A class of REST endpoints that work with a common data type
class RESTEndpointFamily<ResourceType: JSONDecodable, ResourcePageType: JSONDecodable, ResourceCreateRequestType: JSONEncodable, ResourceUpdateRequestType: JSONEncodable>
{
    let url: String
    let requestManager: HTTPRequestManager
    
    init(url: String, requestManager: HTTPRequestManager) {
        self.url = url
        self.requestManager = requestManager
    }
    
    func create(credentials credentials: KnurldCredentials,
                            request: ResourceCreateRequestType,
                            successHandler: (locator: ResourceLocator) -> Void,
                            failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = self.url
        let headers = credentials.toStringMap()
        let body = request.toJSON()
        
        print("CREATE (POST): URL: \(url) headers: \(headers) body: \(body)")
        
        requestManager.postJSON(url: url, headers: headers, body: body,
                                successHandler: { json in
                                    do {
                                        let locator = try ResourceLocator(json: json)
                                        successHandler(locator: locator)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError)
                                        return
                                    }
            },
                                failureHandler: { error in failureHandler(error: error) })
    }
    
    func get(credentials credentials: KnurldCredentials,
                         locator: ResourceLocator,
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
                                        failureHandler(error: .ResponseDeserializationError)
                                        return
                                    }
            },
                                failureHandler: { error in failureHandler(error: error) })
    }
    
    func update(credentials credentials: KnurldCredentials,
                            locator: ResourceLocator,
                            request: ResourceUpdateRequestType,
                            successHandler: (locator: ResourceLocator) -> Void,
                            failureHandler: (error: HTTPRequestError) -> Void)
    {
        let url = locator.getURL()
        let headers = credentials.toStringMap()
        let body = request.toJSON()
        
        print("UPDATE: URL: \(url) headers: \(headers) body: \(body)")
        
        requestManager.postJSON(url: url, headers: headers, body: body,
                                successHandler: { json in
                                    do {
                                        let locator = try ResourceLocator(json: json)
                                        successHandler(locator: locator)
                                        return
                                    } catch {
                                        failureHandler(error: .ResponseDeserializationError)
                                    }
            },
                                failureHandler: { error in failureHandler(error: error) })
    }
    
    func delete(credentials credentials: KnurldCredentials,
                            locator: ResourceLocator,
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
                                print("GET page: Response deserialization error: \(error)")
                                failureHandler(error: .ResponseDeserializationError)
                                return
                            }
                            },
                           failureHandler: { error in failureHandler(error: error) })
    }
}