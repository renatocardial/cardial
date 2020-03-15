//
//  Hero.swift
//  Cardial_Example
//
//  Created by Renato Cardial on 3/8/20.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import Foundation
import Cardial

public struct Hero: Model {
    let id: Int?
    let name: String?
    let description: String?
    let modified: String?
    let resourceURI: String?
    let thumbnail: Thumbnail?
    
    public static func mapJson() -> [String] {
        return ["data", "results"]
    }
}
