//
//  HTTPRequest.swift
//  NetworkFramework
//
//  Created by Anthony Doeraene on 12/08/2024.
//

import Foundation

enum HTTPMethod: String{
    case get = "GET"
    case post = "POST"
}

enum MediaType: String{
    case html = "text/html"
    case json = "application/json"
}

class HTTPRequest{
    
    let method: HTTPMethod
    let path: String
    var headers: [String: String] = [:]
    var body: Data? = nil
    
    init(path: String, method: HTTPMethod = .get){
        self.method = method
        self.path = path
    }
    
    func body(_ value: Data, type: MediaType) -> Self{
        body = value
        headers["Content-Length"] = "\(value.count)"
        headers["Content-Type"] = type.rawValue
        return self
    }
    
    func set_header(for header: String, value: String) -> Self{
        headers[header] = value
        return self
    }
    
    func to_bytes() -> Data{
        let headers_str = headers.map{ header, value in
            "\(header): \(value)"
        }.joined(separator: "\r\n")
        let str = "\(method.rawValue) \(path) HTTP/1.0\r\n\(headers_str)\r\n\n"
        var data = str.data(using: .ascii)!
        if let body{
            data.append(body)
        }
        return data
    }
}
