//
//  Permission.swift
//  Cardial
//
//  Created by Renato Cardial on 3/15/20.
//

import Foundation

public protocol PermissionProtocol: class {
    func havePermission() -> Bool
    func requestPermission() -> Void
    func openSettings() -> Bool
}

public extension PermissionProtocol {
    
    func openSettings() -> Bool {
        if let url = NSURL(string: UIApplicationOpenSettingsURLString) as URL? {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return true
            }
        }
        return false
    }
    
}
