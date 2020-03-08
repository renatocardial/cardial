//
//  LocalData.swift
//  Cardial
//
//  Created by Renato Cardial on 3/5/20.
//  Copyright © 2020 Renato Cardial. All rights reserved.
//

import Foundation

public class LocalData {
    
    public static func saveToFile(for url: URL, data: Data) {
        let fileManager: FileManager = .default
        if let folderURL = try? fileManager.url(for: .documentDirectory,in: .userDomainMask, appropriateFor: nil, create: false) {
            let fileURL = folderURL.appendingPathComponent("\(url.lastPathComponent).cache")
            do {
                try data.write(to: fileURL)
            } catch {
                print(error)
            }
        }
    }

    public static func getToFile(for url: URL) -> Data? {
        let fileManager: FileManager = .default
        if let folderURL = try? fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let data = fileManager.contents(atPath: folderURL.appendingPathComponent("\(url.lastPathComponent).cache").path)
            return data
        }
        return nil
    }
    
}
