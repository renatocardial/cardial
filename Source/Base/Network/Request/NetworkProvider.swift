//
//  NetworkProvider.swift
//  RCore
//
//  Created by Renato Cardial on 10/27/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

import Foundation

open class NetworkProvider {
    
    internal static var queue = OperationQueue()
    
    private static var debug: Bool = false
    
    public typealias ResponseCallback = (success: Bool, model: AnyObject?, error: NetworkError?, statusCode: Int)
    
    public static func endpointRequest<T:Model>(endpoint: Endpoint, model:T.Type, completion:@escaping (_ response: NetworkProvider.ResponseCallback) -> Void ){
        
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation(block: {
            Network.shared.request(endpoint: endpoint, model: T.self) { (response) in
                completion(response)
            }
        })
        
        queue.addOperation(operation)
    }

    public static func endpointRequest(endpoint: Endpoint, completion:@escaping (_ response: NetworkProvider.ResponseCallback) -> Void ) {
       
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation(block: {
            Network.shared.request(endpoint: endpoint, model: Network.NoneModel.self) { (response) in
                completion(response)
            }
        })
        
        queue.addOperation(operation)
    }
    
    public static func noneResponse(errorDefault: NetworkError? = nil) -> NetworkProvider.ResponseCallback {
        return (success: false, model: nil, error: errorDefault, statusCode: 0)
    }
    
    public static func request(api: APIProtocol, path: String, completion:@escaping (_ response: NetworkProvider.ResponseCallback) -> Void ) {
        let endpoint = Endpoint(api: api, method: .GET, path: path)
        NetworkProvider.endpointRequest(endpoint: endpoint) { (response) in
            completion(response)
        }
    }
    
    public static func request<T:Model>(api: APIProtocol, path: String, model: T.Type, params: [String: String]? = nil, completion:@escaping (_ response: NetworkProvider.ResponseCallback) -> Void ) {
        let endpoint = Endpoint(api: api, method: .GET, path: path, params: params )
        NetworkProvider.endpointRequest(endpoint: endpoint, model: model) { (response) in
            completion(response)
        }
    }
    
    public static func setMockSession(mockSession: URLSessionProtocol) {
        Network.shared.mockSession = mockSession
    }
    
    public static func setDebug(debug: Bool) {
        if debug { printAlert("Debug Network Enable") }
        NetworkProvider.debug = debug
    }
    
    public static func isDebugging() -> Bool {
        return debug
    }
}
