//
//  URLSessionDataTaskProtocol.swift
//  Cardial
//
//  Created by Renato Cardial on 3/22/20.
//

import Foundation

public protocol URLSessionDataTaskProtocol {
    func resume()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
