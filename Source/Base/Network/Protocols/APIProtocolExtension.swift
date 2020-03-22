//
//  APIProtocolExtension.swift
//  RCore
//
//  Created by Renato Cardial on 10/26/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

import Foundation

public extension APIProtocol {
    
    var apiKey:String { return "" }
    var extraParamsGET:String {  return "" }
    
    func getBaseUrl() -> String {
        return "\(environments.get().scheme.rawValue)://\(environments.get().host)"
    }
    
    func getJson(data: Data) -> Any? {
        if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            return json
        }
        return nil
    }
    
    func serialize<T:Model>(withArray model:[T].Type,json:AnyObject) -> Decodable? {
        
        guard json is NSNull == false else {
            return nil
        }
        
        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted) {
            //let modelDecode = model as? Decodable.Type
            let decoded = try? model.init(jsonData: jsonData)
            return decoded
        }
            
        return nil
    }
    
    func serialize<T:Model>(model:T.Type,json:AnyObject) -> Decodable? {
        
        guard json is NSNull == false else {
            return nil
        }
        
        do{
           let jsonData: Data = try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
            let decoded = try? model.init(jsonData: jsonData)
            return decoded
        }catch let error{
            print(error)
        }
        return nil
    }
    
    func defaultResponseCallback() -> NetworkProvider.ResponseCallback {
        return (success: false, model: nil, error: nil, statusCode: 0)
    }
    
}

