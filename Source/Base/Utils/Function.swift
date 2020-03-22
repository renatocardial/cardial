//
//  Function.swift
//  Cardial
//
//  Created by Renato Cardial on 2/22/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import Foundation

public func printText(_ text: String, file: String = #file, line: Int = #line) {
    if Environments.currentEnvironment() != EnvironmentKey.production {
        let fileName = (file as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        print("\(fileName):\(line) - \(text)")
    }
}

public func printAny(_ obj: Any, file: String = #file, line: Int = #line) {
    if Environments.currentEnvironment() != EnvironmentKey.production {
        let fileName = (file as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        print("\(fileName):\(line)")
        print(obj)
    }
}

public func printAlert(_ message: String, title: String = "WARNING") {
     print("\(title): *********** >>>>>>>>>>>>>>>> \n\n \(message) \n\n<<<<<<<<<<< ***************\n\n")
}

public func isRunningTests() -> Bool {
    return NSClassFromString("XCTestCase") != nil
}
