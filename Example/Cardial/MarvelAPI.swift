//
//  MarvelAPI.swift
//  Cardial_Example
//
//  Created by Renato Cardial on 3/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//
import Foundation
import Cardial

enum MarvelPath: String {
    case characters = "/v1/public/characters"
    case character = "/v1/public/characters/{characterId}"
    case characterSeries = "/v1/public/characters/{characterId}/series"
    
}

extension MarvelPath {
    func param(key:String, value:String) -> String {
        return self.rawValue.replacingOccurrences(of: key, with: value)
    }
}

class MarvelAPI: APIProtocol {
    
    var environments: Environments
    
    init() {
        
        //This class MarvelAPIKeys isn't here, you should put your own keys
        let publicKey = MarvelAPIKeys.publicKey
        let privateKey = MarvelAPIKeys.privateKey
        
        let ts = NSDate().timeIntervalSince1970
        let hash = "\(ts)\(privateKey)\(publicKey)".md5
        
        let headers = [ "Accept": "application/json" ]
        let extraParamsGET = [ "apikey" : publicKey, "ts" : ts.toString(), "hash" : hash ]
        
        let envProd = Environment(
            host: "gateway.marvel.com",
            scheme: .https,
            headers: headers,
            extraParamsGET: extraParamsGET
        )
        
        environments = Environments(key: .staging, environment: envProd)
        
    }
    
    internal func responseObject(data: Data, endpoint: Endpoint, statusCode: Int) -> NetworkProvider.ResponseCallback {
        
        var responseCallback:NetworkProvider.ResponseCallback = NetworkProvider.noneResponse()
        
        if let json = getJson(data: data) {
            responseCallback.success = true
            responseCallback.model = json as AnyObject
        }
        
        return responseCallback
    }
    
}
