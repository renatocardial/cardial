//
//  NetworkError.swift
//  RCore
//
//  Created by Renato Cardial on 10/26/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

import Foundation

public enum NetworkError: Error {
    case serviceError(message: String)
    case notFound
    case jsonParsing
    case noData
    case invalidUrl
    case noResponse
    case undefined
    case internalServer
    case unauthorized
    
    var customDescription: String {
        switch self {
            case let .serviceError(message):
                return message
            default:
                return self.localizedDescription
        }
        
    }
    
    static func by(statusCode: Int) -> Error? {
        var error: Error? = nil
        switch statusCode {
        case 500:
            error = NetworkError.internalServer
            break
        case 404:
            error = NetworkError.notFound
            break
        default:
            break
        }
        return error
    }
    
}
