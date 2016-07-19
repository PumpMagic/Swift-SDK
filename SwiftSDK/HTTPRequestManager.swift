//
//  HTTPRequestManager.swift
//  SwiftSDK
//
//  A very simple HTTP request library written on top of NSURLSession.
//  Written as an alternative to Alamofire to avoid AF's nonideal error reporting and implicit behavior.
//
//  Created by Ryan Conway on 7/8/16.
//  Copyright © 2016 Knurld. All rights reserved.
//

import Foundation
import Freddy


/// HTTPRequestError captures all reasons that an HTTP request made through HTTPRequestManager could fail.
public enum HTTPRequestError {
    case InvalidURL
    case RequestSerializationError
    case NetworkError
    case NoDataReturned
    case HTTPError(code: Int, body: String?)
    case ResponseDeserializationError(error: JSON.Error?)
    case InternalError
}

/// BodySerializationError indicates a failure to serialize an HTTP request's body.
enum BodySerializationError: ErrorType {
    case FormDataSerializationFailure
    case JSONSerializationFailure
}


/// RepresentableAsFormData indicates the ability to be converted to an HTTP urlencoded form
/// (application/x-www-form-urlencoded).
protocol RepresentableAsURLEncodedForm {
    func asFormData() throws -> NSData
}

/// Extend Dictionary<String, String> for easy conversion to an HTTP urlencoded form.
/// @warn this extension assumes the associated generic types because of Swift's lack of support for
/// conditional conformance. This can be fixed when Swift 3 is out.
extension Dictionary: RepresentableAsURLEncodedForm {
    func asFormData() throws -> NSData {
        func percentEscapeString(string: String) -> String {
            let characterSet = NSCharacterSet(charactersInString: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._* ")
            
            return string
                .stringByAddingPercentEncodingWithAllowedCharacters(characterSet)!
                .stringByReplacingOccurrencesOfString(" ", withString: "+", options: [], range: nil)
        }
        
        var buffer: [String : String] = [:]
        for key in keys {
            if let theKey = key as? String, value = self[key] as? String {
                buffer[theKey] = value
            } else {
                throw BodySerializationError.FormDataSerializationFailure
            }
        }
        
        let formData = buffer.map { "\(percentEscapeString($0))=\(percentEscapeString($1))" }
            .joinWithSeparator("&")
            .dataUsingEncoding(NSUTF8StringEncoding)
        
        guard let theFormData = formData else {
            throw BodySerializationError.FormDataSerializationFailure
        }
        
        return theFormData
    }
}


/// HTTPRequestManager manages and enables the creation of HTTP requests.
class HTTPRequestManager {
    let session: NSURLSession
    static let requestTimeout: NSTimeInterval = 5.0 // seconds
    static let acceptableHTTPResponses = 200...299
    
    init() {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        self.session = NSURLSession(configuration: configuration)
    }
    
    /// Perform an HTTP GET, with no body and expecting JSON in return.
    func get(url url: String, headers: [String: String]?, successHandler: (JSON) -> Void, failureHandler: (HTTPRequestError) -> Void) {
        executeRequest(method: "GET", url: url, headers: headers, body: nil, responseExpected: true,
                       successHandler: { maybeResponse in
                        guard let response = maybeResponse else {
                            failureHandler(.NoDataReturned)
                            return
                        }
                        successHandler(response)
            }, failureHandler: failureHandler)
    }
    
    /// Perform an HTTP DELETE, with no body and expecting nothing in return.
    func delete(url url: String, headers: [String: String]?, successHandler: (Void) -> Void, failureHandler: (HTTPRequestError) -> Void) {
        executeRequest(method: "DELETE", url: url, headers: headers, body: nil, responseExpected: false,
                       successHandler: { _ in successHandler() },
                       failureHandler: failureHandler)
    }
    
    /// Perform an HTTP POST, with a urlencoded form body and expecting JSON in return.
    func postForm(url url: String, headers: [String: String]?, body: RepresentableAsURLEncodedForm, successHandler: (JSON) -> Void, failureHandler: (HTTPRequestError) -> Void)
    {
        // Append the content-type header
        var newHeaders: [String : String] = [:]
        if let headers = headers {
            newHeaders = headers
        }
        newHeaders.updateValue("application/x-www-form-urlencoded", forKey: "Content-Type")
        
        // Try encoding the body and executing the request. If serialization fails, call the failure handler immediately
        do {
            let encodedBody = try body.asFormData()
            executeRequest(method: "POST", url: url, headers: newHeaders, body: encodedBody, responseExpected: true,
                           successHandler: { maybeResponse in
                            guard let response = maybeResponse else {
                                failureHandler(.NoDataReturned)
                                return
                            }
                            successHandler(response)
                }, failureHandler: failureHandler)
        } catch {
            failureHandler(.RequestSerializationError)
        }
    }
    
    /// Perform an HTTP POST, with a JSON body and expecting JSON in return.
    func postJSON(url url: String, headers: [String: String]?, body: JSON, successHandler: (JSON) -> Void, failureHandler: (HTTPRequestError) -> Void)
    {
        // Append the content-type header
        var newHeaders: [String : String] = [:]
        if let headers = headers {
            newHeaders = headers
        }
        newHeaders.updateValue("application/json", forKey: "Content-Type")
        
        // Try encoding the body and executing the request. If serialization fails, call the failure handler immediately
        do {
            let encodedBody = try body.serialize()
            executeRequest(method: "POST", url: url, headers: newHeaders, body: encodedBody, responseExpected: true,
                           successHandler: { maybeResponse in
                            guard let response = maybeResponse else {
                                failureHandler(.NoDataReturned)
                                return
                            }
                            successHandler(response)
                           }, failureHandler: failureHandler)
        } catch {
            failureHandler(.RequestSerializationError)
        }
    }
    
    /// Perform an HTTP POST, with a multipart body and expecting JSON in return.
    func postMultipart(url url: String, headers: [String: String]?, bodies: [String : NSData], successHandler: (JSON) -> Void, failureHandler: (HTTPRequestError) -> Void)
    {
        // Generate a boundary
        let boundary = HTTPRequestManager.generateBoundary()
        
        // Append the content-type header
        var newHeaders: [String : String] = [:]
        if let headers = headers {
            newHeaders = headers
        }
        newHeaders.updateValue("multipart/form-data; boundary=\(boundary)", forKey: "Content-Type")
        
        // Generate the body
        let body = NSMutableData()
        for (paramName, paramValue) in bodies {
            HTTPRequestManager.appendStringToNSData(str: "--\(boundary)\r\n", target: body)
            HTTPRequestManager.appendStringToNSData(str: "Content-Disposition: form-data; name=\"\(paramName)\"\r\n\r\n", target: body)
            body.appendData(paramValue)
        }
        HTTPRequestManager.appendStringToNSData(str: "--\(boundary)\r\n", target: body)
        
        // Execute the request
        executeRequest(method: "POST", url: url, headers: newHeaders, body: body, responseExpected: true,
                       successHandler: { maybeResponse in
                        guard let response = maybeResponse else {
                            failureHandler(.NoDataReturned)
                            return
                        }
                        successHandler(response)
            }, failureHandler: failureHandler)
    }
    
    
    /// Execute an HTTP request, optionally looking for JSON data in the response.
    private func executeRequest(method method: String, url: String, headers: [String: String]?, body: NSData?, responseExpected: Bool, successHandler: (JSON?) -> Void, failureHandler: (HTTPRequestError) -> Void)
    {
        // Let NSURL validate the URL for us
        guard let nsurl = NSURL(string: url) else {
            failureHandler(.InvalidURL)
            return
        }
        
        // Initialize the URL request
        let request = NSMutableURLRequest(URL: nsurl, cachePolicy: .ReloadIgnoringLocalCacheData, timeoutInterval: HTTPRequestManager.requestTimeout)
        
        // Add all user-specified headers to the request
        if let headers = headers {
            for (key, value) in headers {
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        // Set the method
        request.HTTPMethod = method
        
        // Set the body, if given
        if let body = body {
            request.HTTPBody = body
        }
        
        // Make a data task out of our URL request
        let task = session.dataTaskWithRequest(request, completionHandler: { data, response, error in
            HTTPRequestManager.dataTaskCallback(responseExpected: responseExpected,
                successHandler: successHandler,
                failureHandler: failureHandler,
                data: data, response: response, error: error) })
        
        // Start the data task
        task.resume()
    }
    
    
    private static func dataTaskCallback(responseExpected responseExpected: Bool,
                                                  successHandler: (JSON?) -> Void,
                                                  failureHandler: (HTTPRequestError) -> Void,
                                                  data: NSData?, response: NSURLResponse?, error: NSError?)
    {
        if let _ = error {
            // The request did not complete successfully (regardless of return code)
            print("Network error: \(error.debugDescription)")
            failureHandler(.NetworkError)
            return
        } else {
            // Our call succeeded... but is our response good?
            if let response = response {
                // Convert the response to an NSHTTPURLResponse and validate its code
                // All responses should be NSHTTPURLResponses, per Apple's Foundation docs
                guard let httpResponse = response as? NSHTTPURLResponse else {
                    failureHandler(.InternalError)
                    return
                }
                
                print("HTTP response code: \(httpResponse.statusCode)")
                
                let code = httpResponse.statusCode
                if !(HTTPRequestManager.acceptableHTTPResponses ~= code) {
                    if let data = data {
                        failureHandler(.HTTPError(code: code, body: String(data: data, encoding: NSUTF8StringEncoding)))
                    } else {
                        failureHandler(.HTTPError(code: code, body: nil))
                    }
                    return
                }
                
                // If no data is expected by our caller, we're done validating. The call was a success!
                if !responseExpected {
                    successHandler(nil)
                    return
                }
                
                // Parse the received body of data
                guard let data = data else {
                    // No data in the response
                    failureHandler(.NoDataReturned)
                    return
                }
                
                do {
                    let json = try JSON(data: data)
                    print("Received JSON: \(json)")
                    successHandler(json)
                    return
                } catch {
                    failureHandler(.ResponseDeserializationError(error: error as? JSON.Error))
                    return
                }
            }
        }
    }
    
    /// Create boundary string for a multipart/form-data request
    static func generateBoundary() -> String {
        return "----------\(NSUUID().UUIDString)"
    }
    
    static func appendStringToNSData(str str: String, target: NSMutableData) {
        let data = str.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        if let data = data {
            target.appendData(data)
        } else {
            // Foundation docs suggest this should never happen...
            print("ERROR! Unable to convert string to data")
        }
    }
}