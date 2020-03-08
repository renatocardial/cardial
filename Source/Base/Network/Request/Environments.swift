//
//  Environment.swift
//  RCore
//
//  Created by Renato Cardial on 11/20/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

import Foundation

public enum EnvironmentKey {
    case production, staging, testing, development, mocking
}

public class Environments {
    
    private var environments:[EnvironmentKey: Environment] = [:]
    private static var current: EnvironmentKey?
    
    public init(key: EnvironmentKey, environment: Environment) {
        environments[key] = environment
        Environments.current = key
    }
    
    public func add(key: EnvironmentKey, environment: Environment, isCurrent: Bool = false) {
        environments[key] = environment
        if isCurrent {
            Environments.current = key
        }
    }
    
    public func get(key: EnvironmentKey) -> Environment {
        guard let environment = environments[key] else {
            return environments.first!.value
        }
        return environment
    }
    
    public func get() -> Environment {
        if let current = Environments.current {
            return get(key: current)
        }
        return environments.first!.value
    }
    
    public func setCurrent(key: EnvironmentKey) {
        Environments.current = key
    }
    
    public static func currentEnvironment() -> EnvironmentKey? {
        return Environments.current
    }
}
