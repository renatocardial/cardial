//
//  MockSessionDataTask.swift
//  Cardial
//
//  Created by Renato Cardial on 3/22/20.
//

import Foundation

class MockSessionDataTask: URLSessionDataTaskProtocol {
    
    typealias ResponseCompletion = (Data?, URLResponse?, Error?) -> Void
    
    let completion: ResponseCompletion
    let request: URLRequest
    
    init(request: URLRequest, completionHandler: @escaping ResponseCompletion) {
        self.request = request
        self.completion = completionHandler
    }
    
    func dataMock(request: URLRequest) -> Data? {
        
        if let components = request.url?.pathComponents {
            let path = components.dropFirst().joined(separator: "/")
            let method = request.httpMethod?.lowercased() ?? ""
            return getDataFromFile(fileName: "\(method)@\(path)")
        }
        
        return nil
    }
    
    private func getDataFromFile(fileName: String) -> Data? {
        var data: Data? = nil
        if let path = Bundle.main.path(forResource: fileName.replacingOccurrences(of: "/", with: "|"), ofType: "json") {
            do {
                let fileUrl = URL(fileURLWithPath: path)
                data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
                return data
            } catch {
                printText(error.localizedDescription)
            }
        }
        return data
    }
    
    func resume() {
        let data = dataMock(request: request)
        var statusCode = 200
        if data == nil {
            statusCode = 404
        }
        
        var response: URLResponse? = nil
        if let url = request.url {
            response = HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)
        }
        
        completion(data, response, nil)
    }
    
}


