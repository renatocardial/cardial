//
//  StringExtension.swift
//  RCore
//
//  Created by Renato Cardial on 10/26/19.
//  Copyright © 2019 Renato Cardial. All rights reserved.
//
import Foundation
import CommonCrypto

public extension String {
    
    var md5: String {
        let data = Data(self.utf8)
        let hash = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> [UInt8] in
            var hash = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
            CC_MD5(bytes.baseAddress, CC_LONG(data.count), &hash)
            return hash
        }
        return hash.map { String(format: "%02x", $0) }.joined()
    }
    
    func strpos(needle: String) -> Int {
        //Returns the index of the first occurrence of a substring in a string, or -1 if absent
        if let range = self.range(of: needle){
            return self.distance(from: self.startIndex, to: range.lowerBound)
        } else {
            return -1
        }
        
    }
    
    func substring(start: Int, length: Int) -> String {
        let idxStart = self.index(self.startIndex, offsetBy: start)
        if (idxStart.utf16Offset(in: self) + length) > self.count {
            return String(self[idxStart...])
        }else{
            let idxEnd = self.index(idxStart, offsetBy: length)
            return String(self[idxStart..<idxEnd])
        }
    }
    
    func trim() -> String {
       return self.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}

