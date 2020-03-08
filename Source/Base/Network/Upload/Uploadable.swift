//
//  Uploadable.swift
//  Cardial
//
//  Created by Renato Cardial on 3/3/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import Foundation

public enum MimeType: String {
    case zip = "application/zip"
    case text = "text/plain"
    case jpg = "image/jpeg"
    case json = "application/json"
    case png = "image/png"
    case pdf = "application/pdf"
    case tif = "image/tiff"
}

public class UploadReceive {
    var finished: ((Error?, URLSessionUploadTask?, String) -> Void)!
    var progress: ((Int, String) -> Void)?
}

open class Uploadable: Operation, URLSessionDataDelegate, URLSessionTaskDelegate, UploadableProtocol {
    public var id: String = UUID().uuidString
    public var url: URL
    public var data: Data
    public var mimeType: MimeType
    public var fileName: String
    public var fieldName: String
    public var param: [String : String]?
    public var uploadReceive: UploadReceive = UploadReceive()
    
    private var suspended: Bool = false
    private var uploadTask: URLSessionUploadTask?
    
    public init(url: URL, id: String? = nil, fileName: String, data: Data, mimeType: MimeType, fieldName: String = "FILE", param: [String : String]? = nil) {
        self.url = url
        self.data = data
        self.fileName = fileName
        self.fieldName = fieldName
        self.mimeType = mimeType
        self.param = param
        
        if let id = id {
            self.id = id
        }
    }
}

public protocol UploadableProtocol: URLSessionDelegate {
    var id: String { get set }
    var url: URL { get }
    var data: Data { get }
    var mimeType: MimeType { get }
    var fileName: String { get }
    var fieldName: String { get }
    var param: [String: String]? { get }
    var uploadReceive: UploadReceive { get set }
    func upload(finished: ((Error?, URLSessionUploadTask?, String) -> Void)!, progress: ((Int, String) -> Void)?)
    func stop(cancel: Bool)
}

public extension Uploadable {
    
    func upload(finished: ((Error?, URLSessionUploadTask?, String) -> Void)!, progress: ((Int, String) -> Void)? = nil){
        
        defer { suspended = false }
        
        uploadReceive.finished = finished
        uploadReceive.progress = progress
        
        if suspended {
            uploadTask?.resume()
            return
        }
        
        var request = URLRequest(url: self.url)
        request.httpMethod = "POST"

        let boundary = "Boundary-\(NSUUID().uuidString)"

        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let dataSend = createBodyWithParameters(parameters: param, mimetype: mimeType.rawValue, fieldName: fieldName, filename: fileName, dataKey: data, boundary: boundary)
        
        let configuration = URLSessionConfiguration.default
        configuration.isDiscretionary = false
        
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        
        let task = session.uploadTask(with: request, from: dataSend)
        task.resume()
        uploadTask = task
    }
    
    func stop(cancel: Bool = false) {
        if cancel {
            uploadTask?.cancel()
        } else {
            suspended = true
            uploadTask?.suspend()
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
        let percentUploaded = Float(totalBytesSent) / Float(totalBytesExpectedToSend)
        let percent = percentUploaded * 100
        DispatchQueue.main.async {
            self.uploadReceive.progress?(Int(percent), self.id)
        }
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        DispatchQueue.main.async {
            self.uploadReceive.finished(error, nil, self.id)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        var myError: Error? = error
        if let statusCode = (task.response as? HTTPURLResponse)?.statusCode {
            guard let statusError = NetworkError.by(statusCode: statusCode) else {
                return
            }
            myError = statusError
        }
        self.uploadReceive.finished(myError, nil, self.id)
    }
    
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print(String(data: data, encoding: .utf8) as Any)
        DispatchQueue.main.async {
            self.uploadReceive.finished(nil, dataTask as? URLSessionUploadTask, self.id)
        }
    }
    
    private func createBodyWithParameters(parameters: [String : String]?, mimetype: String, fieldName: String?, filename:String, dataKey: Data, boundary: String) -> Data {
        var body = Data()
        if parameters != nil {
            
            for (key, value) in parameters! {
                body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        if let fieldName = fieldName {
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
            body.append(dataKey)
            body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        }
        
        return body
    }
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(NSUUID().uuidString)"
    }
}
