//
//  QuicheClient.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 08/09/2024.
//

import Foundation

enum QuicheError: Error{
    case requestError(String)
}

extension QuicheError: LocalizedError{
    public var errorDescription: String? {
            switch self {
            case .requestError(let desc):
                return NSLocalizedString("Failed to fetch data from the server: \(desc)", comment: "Fetching error")
            }
        }
}

struct QuicheClient: QuicClient{
    var name: String = "quiche"
    var id: String { name }
    var options: [any Option] = []
    var transfer: TransferWrapper = TransferWrapper(transfer: QuicTransfer.aioquic)
    
    var mode: URLSessionConfiguration.MultipathServiceType = .none
    
    func fetch(url: URL) async throws -> Data {
        options.forEach{ option in
            option.apply(client: self)
        }
        let host = Utils.makeCString(from: url.host()!)
        let port = Utils.makeCString(from: "443")
        var pathString = url.path()
        if pathString == ""{
            pathString = "/"
        }
        let path = Utils.makeCString(from: pathString)
        
        let raw_response = quiche_fetch(host, port, path)
        let response = QuicheResponse(raw_response: raw_response?.pointee)
        guard response.status == 0 else {
            throw QuicheError.requestError(response.data!)
        }
        let data = response.data ?? "Empty response"
        return data.data(using: .utf8)!
    }
}

extension QuicheClient{
    var hasMode: Bool{
        false
    }
}
