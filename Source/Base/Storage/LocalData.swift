//
//  LocalData.swift
//  Cardial
//
//  Created by Renato Cardial on 3/5/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import Foundation

public class LocalData {
    
    public static func saveToFile(for key: String, data: Data, in directory: FileManager.SearchPathDirectory = .documentDirectory) {
        let fileManager: FileManager = .default
        if let folderURL = try? fileManager.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let fileURL = folderURL.appendingPathComponent("\(key).cache")
            do {
                try data.write(to: fileURL)
            } catch {
                print(error)
            }
        }
    }

    public static func getToFile(for key: String, in directory: FileManager.SearchPathDirectory = .documentDirectory) -> Data? {
        let fileManager: FileManager = .default
        if let folderURL = try? fileManager.url(for: directory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let data = fileManager.contents(atPath: folderURL.appendingPathComponent("\(key).cache").path)
            return data
        }
        return nil
    }
    
}
