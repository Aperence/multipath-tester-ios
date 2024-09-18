//
//  MPTCPClient.swift
//  test-mptcp
//
//  Created by Anthony Doeraene on 31/07/2024.
//

import Foundation

struct URLSessionClient : MPTCPClient{
    
    var name: String = "URLSessionClient"
    var id: String { name }
    var transfer: TransferWrapper = TransferWrapper(transfer: MPTCPTransfers.check)
    
    var options: [any Option] = [MultipathMode(value: .none)]
    
    var session: URLSession = URLSession.shared
    
    func fetch(url: URL) async throws -> Data {
        options.forEach{ option in
            option.apply(client: self)
        }
        var req = URLRequest(url: url)
        // get a shorter description to know if we are using mptcp
        req.addValue("curl/7.54.1", forHTTPHeaderField: "User-Agent")
        
        let (data, _) = try await session.data(for: req)
        return data
    }
}
