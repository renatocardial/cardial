//
//  Environment.swift
//  RCore
//
//  Created by Renato Cardial on 11/20/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

import Foundation

public struct Environment: Equatable {
    let host: String
    let scheme: Scheme
    let port: Int?
    
    var extraParamsGET: [String:String]?
    var headers: [String:String]?
    
    public init(host: String, scheme: Scheme, port: Int? = nil, headers: [String:String]? = nil, extraParamsGET: [String:String]? = nil) {
        
        self.host = host
        self.scheme = scheme
        self.port = port
        self.headers = headers
        self.extraParamsGET = extraParamsGET
        
    }
}
