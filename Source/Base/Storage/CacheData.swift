//
//  CacheData.swift
//  FROM https://github.com/sgl0v/OnSwiftWings
//

import Foundation

public class CacheData {
    
    public static var shared: CacheData = CacheData()
    
    // 1st level cache, that contains encoded images
    private lazy var dataCache: NSCache<AnyObject, AnyObject> = {
        let cache = NSCache<AnyObject, AnyObject>()
        cache.countLimit = config.countLimit
        cache.totalCostLimit = config.memoryLimit
        return cache
        
    }()
    
    private let lock = NSLock()
    private let config: Config

    public struct Config {
        let countLimit: Int
        let memoryLimit: Int
        static let defaultConfig = Config(countLimit: 100, memoryLimit: 1024 * 1024 * 100) // 100 MB
    }

    init(config: Config = Config.defaultConfig) {
        self.config = config
    }
    
    public func add(_ data: Data?, for url: URL) {
        guard let data = data else { return remove(for: url) }
        lock.lock(); defer { lock.unlock() }
        dataCache.setObject(data as AnyObject, forKey: url as AnyObject)
    }
    
    public func remove(for url: URL) {
        lock.lock(); defer { lock.unlock() }
        dataCache.removeObject(forKey: url as AnyObject)
    }
    
    public func get(for url: URL) -> Data? {
        lock.lock(); defer { lock.unlock() }
        if let data = dataCache.object(forKey: url as AnyObject) as? Data {
            return data
        }
        return nil
    }
    
}

extension CacheData {
    subscript(_ key: URL) -> Data? {
        get {
            return get(for: key)
        }
        set {
            return add(newValue, for: key)
        }
    }
}
