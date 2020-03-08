//
//  APIProtocol.swift
//  RCore
//
//  Created by Renato Cardial on 10/26/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

import Foundation

public protocol APIProtocol {
    var environments: Environments { get }
    func getBaseUrl() -> String
    func responseObject(data: Data, endpoint: Endpoint, statusCode: Int) -> NetworkProvider.ResponseCallback
}

