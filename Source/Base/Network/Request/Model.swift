//
//  File.swift
//  RCore
//
//  Created by Renato Cardial on 10/26/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//

public protocol Model: Decodable {
    static func mapJson() -> [String]
}

public extension Model {
    static func mapJson() -> [String] {  return [] }
}
