//
//  MPTCPClientNetworkWrapper.swift
//  mptcp-example
//
//  Created by Anthony Doeraene on 16/08/2024.
//

import Foundation
import Network

enum RequestNetworkError: Error{
    case emptyBody
    case invalidStatusCode(Int)
    case failedToConnect
}

extension RequestNetworkError: LocalizedError{
    public var errorDescription: String? {
            switch self {
            case .invalidStatusCode(let code):
                return NSLocalizedString("Failed to fetch data from the server, received status code \(code)", comment: "Fetching error")
            case .emptyBody:
                return NSLocalizedString("Received empty body", comment: "Fetching error")
            case .failedToConnect:
                return NSLocalizedString("Failed to connect to the server", comment: "")
            }
        }
}

struct MPTCPClientNetwork: MPTCPClient{
    var name: String = "NetworkClient"
    
    var id: String { name }
    
    var options: [any Option] = [MultipathMode(value: .none)]
    var transfer: TransferWrapper = TransferWrapper(transfer: MPTCPTransfers.check)
    
    var params: NWParameters = .tls
    
    func fetch(url: URL) async throws -> Data {
        options.forEach{ option in
            option.apply(client: self)
        }
        let client = try NetworkClient(to: .url(url), params: params)
        
        var path = url.path()
        if path == "" { path = "/" }
        let response = try await client.get(path: path)
        if response.code != 200{
            throw RequestNetworkError.invalidStatusCode(response.code)
        }
        guard let body = response.body else { throw RequestNetworkError.emptyBody }
        return body.data(using: .ascii)!
    }
}
