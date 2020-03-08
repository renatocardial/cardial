//
//  DownloadQueue.swift
//  Cardial
//
//  Created by Renato Cardial on 3/7/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import Foundation

public class SyncQueue {
    
    public init() {}
    
    private var uploadables: [Uploadable] = []
    private var downloadables: [Downloadable] = []
    
    public func add(uploadable: Uploadable) {
        uploadables.append(uploadable)
    }
    
    public func add(downloadable: Downloadable) {
        downloadables.append(downloadable)
    }
    
    public func remove(uploadable: Uploadable) -> Bool {
        if let index = uploadables.firstIndex(of: uploadable) {
            uploadables.remove(at: index)
            return true
        }
        return false
    }
    
    public func remove(downloadable: Downloadable) -> Bool {
        if let index = downloadables.firstIndex(of: downloadable) {
            downloadables.remove(at: index)
            return true
        }
        return false
    }
    
    public func removeAllDownloads() {
        downloadables.removeAll()
    }
    
    public func removeAllUploads() {
        uploadables.removeAll()
    }
    
    public func stopAllDownloads(cancel: Bool = false) {
        downloadables.forEach {
            $0.stop(cancel: cancel)
        }
    }
    
    public func stopAllUploads(cancel: Bool = false) {
        uploadables.forEach {
            $0.stop(cancel: cancel)
        }
    }
    
    public func startDownload(dowloaded: @escaping (Bool, String, Data?) -> Void, progress: ((Int, String) -> Void)? = nil) {
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        let total = downloadables.count
        var count = 0
        downloadables.forEach {
            let item = $0
            let operation = BlockOperation {
                item.download(finished: {(error, data, id) in
                    count += 1
                    dowloaded(total == count, id, data)
                }) { (progressValue, id) in
                    print("Download: progress \(progressValue) - idx = \(id)")
                    progress?(progressValue, id)
                }
            }
            operationQueue.addOperation(operation)
        }
    }
    
    public func startUpload(uploaded: @escaping (Bool, String, URLSessionUploadTask?) -> Void, progress: ((Int, String) -> Void)? = nil) {
        
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 1
        
        let total = self.uploadables.count
        var count = 0
        self.uploadables.forEach {
            let item = $0
            let operation = BlockOperation {
            
                item.upload(finished: { (error, uploadTask, id) in
                    count += 1
                    uploaded(total == count, id, uploadTask)
                }) { (progressValue, id) in
                    progress?(progressValue, id)
                }
            }
            operationQueue.addOperation(operation)
        }
        
    }
    
}
