//
//  HTTPResponse.swift
//  NetworkFramework
//
//  Created by Anthony Doeraene on 12/08/2024.
//

import Foundation

extension Collection {

    /// Returns the element at the specified index if it exists, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

public class HTTPResponse{
    
    public let code: Int
    public let body: String?
    
    init(from bytes: Data) throws{
        let str = String(data: bytes, encoding: .ascii)!
        let splitted = str.components(separatedBy: "\r\n\r\n")
        let header = splitted[0]
        body = splitted[safe: 1]
        
        let first_line = header.components(separatedBy: "\n")[0]
        code = Int(first_line.components(separatedBy: " ")[1])!
    }
}
