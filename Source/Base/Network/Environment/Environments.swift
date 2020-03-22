//
//  Environment.swift
//  RCore
//
//  Created by Renato Cardial on 11/20/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

import Foundation

public enum EnvironmentKey: String {
    case production, staging, testing, development, mocking
}

public class Environments {
    
    private var environments:[EnvironmentKey: Environment] = [:]
    private var current: EnvironmentKey
    private static var lastCurrent: EnvironmentKey?
    
    public init(key: EnvironmentKey, environment: Environment) {
        environments[key] = environment
        Environments.lastCurrent = key
        current = key
    }
    
    public func add(key: EnvironmentKey, environment: Environment, isCurrent: Bool = false) {
        environments[key] = environment
        if isCurrent {
            Environments.lastCurrent = key
            current = key
        }
    }
    
    public func get(key: EnvironmentKey) -> Environment {
        guard let environment = environments[key] else {
            return environments.first!.value
        }
        return environment
    }
    
    public func get() -> Environment {
        return get(key: current)
    }
    
    public func setCurrent(key: EnvironmentKey) {
        current = key
        Environments.lastCurrent = key
    }
    
    public func environmentKey() -> EnvironmentKey {
        return current
    }
    
    public static func currentEnvironment() -> EnvironmentKey? {
        return Environments.lastCurrent
    }
}
