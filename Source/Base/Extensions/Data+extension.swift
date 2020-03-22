//
//  Data+extension.swift
//  Cardial
//
//  Created by Renato Cardial on 3/22/20.
//

import Foundation

extension Data {
    
    func prettyJSON() -> String {
        var result = ""
        if let object = try? JSONSerialization.jsonObject(with: self, options: []) {
            if let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]) {
                result = String(data: data, encoding: .utf8) ?? ""
            }
        } else {
            result = String(data: self, encoding: .utf8) ?? ""
        }
        return result
    }
    
}
