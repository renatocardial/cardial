//
//  Network.swift
//  RCore
//
//  Created by Renato Cardial on 10/26/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

import Foundation


internal class Network {
    
    typealias callbackCompletionResponse = (_ response:NetworkProvider.ResponseCallback) -> Void
    
    static var shared: Network = Network()
    
    var session: URLSessionProtocol
    var sessionConfig: URLSessionConfiguration?
    var reachability: Reachability? = try? Reachability()
    
    var mockSession: URLSessionProtocol = MockSession() {
        didSet {
            if isRunningTests() {
                session = self.mockSession
            }
        }
    }
    
    struct NoneModel: Model {
        typealias Serializable = NoneModel
    }
    
    init() {
        session = URLSession.shared
    }
    
    private func checkIfIsMock(endpoint: Endpoint) -> Bool {
        let environment = endpoint.api.environments.environmentKey()

        if endpoint.isMocking {
            session = mockSession
            printAlert("Endpoint: \(endpoint.path) is Mocking \nEnvironment: \(environment.rawValue)")
            return true
        } else if (isRunningTests() && endpoint.mockInTest) || environment == .mocking {
            session = mockSession
            print("Mock Network:  \(endpoint.path)")
            return true
        } else {
            session = URLSession.shared
        }
        
        return false
    }
    
    func request<T:Model>(endpoint: Endpoint, model: T.Type, completion: @escaping callbackCompletionResponse){
        
        guard let request = getUrlRequest(endpoint: endpoint) else {
            completion(NetworkProvider.noneResponse(errorDefault: NetworkError.invalidUrl))
            return
        }
        
        let isMock = checkIfIsMock(endpoint: endpoint)
        isConnected { [weak self] (connected) in
            if connected || isMock {
                self?.session.dataTask(with: request) { (data, response, error) in
                    DispatchQueue.global().async {
                        if endpoint.offlineMode, let dataToCache = data {
                            LocalData.saveToFile(for: endpoint.fileName(), data: dataToCache, in: .cachesDirectory)
                        }
                        self?.callbackResponse(response: response, data: data, error: error, endpoint: endpoint, model: model, callback: completion)
                    }
                }.resume()
            } else {
                if endpoint.offlineMode && endpoint.method == .GET {
                    if let data = LocalData.getToFile(for: endpoint.fileName(), in: .cachesDirectory) {
                        if let url = endpoint.getURL() {
                            let response = HTTPURLResponse(url: url, statusCode: 304, httpVersion: nil, headerFields: nil)
                            self?.callbackResponse(response: response, data: data, error: nil, endpoint: endpoint, model: model, callback: completion)
                            return
                        }
                    }
                }
                
                completion(NetworkProvider.noneResponse(errorDefault: NetworkError.noConnection))
            }
        }
        
    }
    
    private func getUrlRequest(endpoint: Endpoint) -> URLRequest? {
        guard let url = endpoint.getURL() else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        
        if let headers = endpoint.api.environments.get().headers {
            headers.forEach {
                request.setValue($0.value, forHTTPHeaderField: $0.key)
            }
        }
        
        if(endpoint.method == .POST){
            request.httpBody = endpoint.getParamsToPost()
        }
        
        return request
    }
       
    private func callbackResponse<T:Model>(response: URLResponse?, data: Data?, error: Error?, endpoint:Endpoint, model: T.Type, callback: @escaping callbackCompletionResponse) {
        
        var responseCallback: NetworkProvider.ResponseCallback = NetworkProvider.noneResponse()
        
        guard let httpResponse = response as? HTTPURLResponse else {
            responseCallback.error = NetworkError.noResponse
            callback(responseCallback)
            return
        }
        
        responseCallback.statusCode = httpResponse.statusCode
        if error != nil {
            responseCallback.error = NetworkError.serviceError(message: error.debugDescription)
            callback(responseCallback)
        } else {
            if let usableData = data {
                
                if NetworkProvider.isDebugging() {
                    print("Url: \(endpoint.getFullPath() ?? "")")
                    print("Params:")
                    print(endpoint.params ?? "")
                    print("Response:")
                    print(usableData.prettyJSON())
                }
                
                if model is NoneModel.Type {
                    responseCallback = endpoint.api.responseObject(data: usableData, endpoint: endpoint, statusCode: httpResponse.statusCode)
                } else {
                    var dataObject = usableData
                    let paths = model.mapJson()
                    var isArray = false
                    if paths.count > 0 {
                        if let json = endpoint.api.getJson(data: usableData) as? [String: Any] {
                            var dictionary: Any = json
                            for path in paths {
                                if let item = mapping(item: dictionary, path: path) {
                                    dictionary = item
                                }
                            }
                            
                            if let _ = dictionary as? [Any] {
                                isArray = true
                            }
                            
                            if let newDataObject = try? JSONSerialization.data(withJSONObject: dictionary, options: []) {
                                dataObject = newDataObject
                            }
                            
                        }
                    }
                    
                    if isArray {
                        let modelArray = [T].self
                        if let model = try? JSONDecoder.init().decode(modelArray, from: dataObject) {
                            responseCallback.success = true
                            responseCallback.model = model as AnyObject
                        } else {
                            responseCallback.error = NetworkError.jsonParsing
                        }
                    } else {
                        if let model = try? JSONDecoder.init().decode(model, from: dataObject) {
                            responseCallback.success = true
                            responseCallback.model = model as AnyObject
                        } else {
                            responseCallback.error = NetworkError.jsonParsing
                        }
                    }
                    
                }
                callback(responseCallback)
            } else {
                responseCallback.error = NetworkError.noData
                callback(responseCallback)
            }
        }
    }
    
    private func mapping(item: Any, path: String) -> Any? {
        if let dictionary = item as? [String: Any] {
            if let obj = dictionary[path] as? [String: Any] {
                return obj
            } else {
                return dictionary[path]
            }
        }
        return item
    }
    
    func isConnected(completion: @escaping (Bool) -> Void) {
        reachability?.whenReachable = { [weak self] value in
            if value.connection == .wifi || value.connection == .cellular {
                completion(true)
            } else {
                completion(false)
            }
            self?.reachability?.stopNotifier()
        }
        
        reachability?.whenUnreachable = { [weak self] value in
            if value.connection == .wifi || value.connection == .cellular {
                completion(true)
            } else {
                completion(false)
            }
            self?.reachability?.stopNotifier()
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            completion(true)
        }
    }
    
}
