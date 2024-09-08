//
//  Utils.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 08/09/2024.
//

import Foundation

struct Utils{
    // https://gist.github.com/yossan/51019a1af9514831f50bb196b7180107
    static func makeCString(from str: String) -> UnsafeMutablePointer<Int8> {
        let count = str.utf8.count + 1
        let result = UnsafeMutablePointer<Int8>.allocate(capacity: count)
            str.withCString { (baseAddress) in
            result.initialize(from: baseAddress, count: count)
            }
        return result
    }
}
