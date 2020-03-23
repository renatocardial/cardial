//
//  Endpoint.swift
//  RCore
//
//  Created by Renato Cardial on 10/26/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

import Foundation

public struct Endpoint {
    
    var rawValue:String { return "Endpoint" }
    var api: APIProtocol
    var method: HTTPMethod
    var path: String
    var params: [String: String]?
    var postType: PostType?
    var mockInTest: Bool = false
    var isMocking: Bool = false
    var offlineMode: Bool = false
    
    public init(api: APIProtocol, method: HTTPMethod, path: String, params: [String: String]? = nil, postType: PostType? = nil, mockInTest: Bool = false, isMocking: Bool = false, offlineMode: Bool = false) {
        self.api = api
        self.method = method
        self.path = path
        self.params = params
        self.postType = postType
        self.mockInTest = mockInTest
        self.isMocking = isMocking
        self.offlineMode = offlineMode
    }
    
    internal func getURL() -> URL? {
        return getUrlComponents().url
    }
    
    private func getPath() -> (path: String, params: [String:String]?) {
        
        var myPath = path.first == "/" ? path : "/\(path)"
        var params: [String:String] = [:]
        if myPath.contains("?") {
            let split = myPath.split(separator: "?")
            myPath = String(split.first!)
            if let myParams = split.last {
                for pair in myParams.components(separatedBy: "&") {
                    let key = pair.components(separatedBy: "=")[0]

                    let value = pair
                        .components(separatedBy:"=")[1]
                        .replacingOccurrences(of: "+", with: " ")
                        .removingPercentEncoding ?? ""
                    
                    params[key] = value
                }
            }
        }
        
        return (path: myPath, params: params.keys.count > 0 ? params : nil)
    }
    
    internal func getUrlComponents() -> URLComponents {
        
        let env = api.environments.get()
        var queryItems: [URLQueryItem] = []
        var urlComponents = URLComponents()
        
        let pathTuple = getPath()
        urlComponents.path = pathTuple.path
        urlComponents.host = env.host
        urlComponents.scheme = env.scheme.rawValue
        if let port = env.port {
            urlComponents.port = port
        }
        
        if method == .GET {
            
            if let extraParams = api.environments.get().extraParamsGET {
                extraParams.forEach {
                    queryItems.append(URLQueryItem(name: $0.key, value: $0.value))
                }
            }
            
            if let params = self.params {
                params.forEach {
                    queryItems.append(URLQueryItem(name: $0.key, value: $0.value))
                }
            }
            
            if let params = pathTuple.params {
                params.forEach {
                    queryItems.append(URLQueryItem(name: $0.key, value: $0.value))
                }
            }
            
            if queryItems.count > 0 {
                urlComponents.queryItems = queryItems
            }
        }
        
        return urlComponents
    }
    
    internal func getFullPath() -> String? {
        return getUrlComponents().url?.absoluteString
    }
    
    func getParamsToPost() -> Data? {
        if let postType = self.postType {
            if postType == .json {
                return getParamsToJsonPost()
            } else {
                return getParamsToPostString()
            }
        }
        return nil
    }
    
    // MARK: Private Methods
    
    private func getParamsToPostString() -> Data? {
        if let params = self.params {
            let array = params.map {
                "\($0.key)=\($0.value)"
            }
            return array.joined(separator: "&").data(using: .utf8)
        }
        return nil
    }
    
    private func getParamsToJsonPost() -> Data? {
        if let params = self.params {
            if let data = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                return data
            }
        }
        return nil
    }
    
    func fileName() -> String {
        var str = self.path
        str += self.method.rawValue
        str += self.params?.description ?? ""
        return str
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "?", with: "-")
            .replacingOccurrences(of: "=", with: "_")
            .replacingOccurrences(of: "&", with: "-")
    }
    
}
