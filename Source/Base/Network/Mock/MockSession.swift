//
//  MockSession.swift
//  Cardial
//
//  Created by Renato Cardial on 3/22/20.
//

import Foundation

class MockSession: URLSessionProtocol {
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        return MockSessionDataTask(request: request, completionHandler: completionHandler)
    }
    
}
