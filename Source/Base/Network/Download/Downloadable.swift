//
//  Downloadable.swift
//  Cardial
//
//  Created by Renato Cardial on 2/1/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import Foundation

public class DownloadReceive {
    var finished: ((Error?, Data?, String) -> Void)!
    var progress: ((Int, String) -> Void)?
}

open class Downloadable: Operation, URLSessionDataDelegate, URLSessionTaskDelegate, DownloadableProtocol {
    
    public var id: String = UUID().uuidString
    public var url: URL
    public var downloadReceive: DownloadReceive = DownloadReceive()
    private let memoryCache: Bool
    private var downloading: Bool = false
    private var downloadTask: URLSessionDownloadTask?
    private var resumeData: Data?
    
    public init(url: URL, id: String? = nil, memoryCache: Bool = true) {
        self.url = url
        self.memoryCache = memoryCache
        if let id = id {
            self.id = id
        }
    }
}

public protocol DownloadableProtocol: URLSessionDownloadDelegate {
    var id: String { get set }
    var url: URL { get }
    var downloadReceive: DownloadReceive { get set }
    func download(finished: ((Error?, Data?, String) -> Void)!, progress: ((Int, String) -> Void)?)
    func stop(cancel: Bool)
    func isDownloading() -> Bool
}

public extension Downloadable {
    
    func isDownloading() -> Bool {
        return downloading
    }
    
    func download(finished: ((Error?, Data?, String) -> Void)!, progress: ((Int, String) -> Void)? = nil){
        
        self.downloadReceive.finished = finished
        self.downloadReceive.progress = progress
        
        if memoryCache {
            if let data = CacheData.shared.get(for: self.url) {
                DispatchQueue.main.async {
                    self.downloadReceive.finished(nil, data, self.id)
                    self.downloadReceive.progress?(100, self.id)
                }
                return
            }
        }
        
        downloading = true
        
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        let request = URLRequest(url: url)
        
        if let data = resumeData  {
            let task = session.downloadTask(withResumeData: data)
            task.resume()
            self.downloadTask = task
        }else{
            let task = session.downloadTask(with: request)
            task.resume()
            self.downloadTask = task
        }
        
    }
    
    func stop(cancel: Bool = false) {
        if cancel {
            downloadTask?.cancel()
        } else {
            downloadTask?.cancel(byProducingResumeData: { [weak self] (data) in
                self?.resumeData = data
            })
        }
        downloading = false
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let percentDownloaded: Float = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        let percent = percentDownloaded * 100
        if percent >= 0 {
            DispatchQueue.main.async {
                self.downloadReceive.progress?(Int(percent), self.id)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        do {
            let reader = try FileHandle(forReadingFrom: location)
            let data =  reader.readDataToEndOfFile()
            if memoryCache {
                CacheData.shared.add(data, for: self.url)
            }
            DispatchQueue.main.async {
                self.downloadReceive.finished(nil, data, self.id)
            }
        } catch {
            if memoryCache {
                CacheData.shared.remove(for: self.url)
            }
            DispatchQueue.main.async {
                self.downloadReceive.finished(error, nil, self.id)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let error = error else {
            var myError: Error = NetworkError.invalidUrl
            if let statusCode = (task.response as? HTTPURLResponse)?.statusCode {
                guard let statusError = NetworkError.by(statusCode: statusCode) else {
                    return
                }
                myError = statusError
            }
            self.downloadReceive.finished(myError, nil, self.id)
            return
        }
        
        let userInfo = (error as NSError).userInfo
        if let resumeData = userInfo[NSURLSessionDownloadTaskResumeData] as? Data {
            self.resumeData = resumeData
        } else {
            self.downloadReceive.finished(error, nil, self.id)
        }
        downloading = false
    }
    
}
