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
    
    public typealias ResponseCallback = (success: Bool, model: AnyObject?, error: NetworkError?, statusCode: Int)
    
    public static func request<T:Model>(endpoint: Endpoint, model:T.Type, pathJson: [String]? = nil, completion:@escaping (_ response: NetworkProvider.ResponseCallback) -> Void ){
        
        queue.maxConcurrentOperationCount = 1
        
        let operation = BlockOperation(block: {
            Network.shared.request(endpoint: endpoint, model: T.self) { (response) in
                completion(response)
            }
        })
        
        queue.addOperation(operation)
    }

    public static func request(endpoint: Endpoint, completion:@escaping (_ response: NetworkProvider.ResponseCallback) -> Void ) {
       
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
    
    public static func get(api: APIProtocol, path: String, completion:@escaping (_ response: NetworkProvider.ResponseCallback) -> Void ) {
        let endpoint = Endpoint(api: api, method: .GET, path: path )
        NetworkProvider.request(endpoint: endpoint) { (response) in
            completion(response)
        }
    }
    
    public static func get<T:Model>(api: APIProtocol, path: String, model: T.Type, pathJson: [String]? = nil, params: [String: String]? = nil, completion:@escaping (_ response: NetworkProvider.ResponseCallback) -> Void ) {
        let endpoint = Endpoint(api: api, method: .GET, path: path, params: params )
        NetworkProvider.request(endpoint: endpoint, model: model) { (response) in
            completion(response)
        }
    }
    
}
