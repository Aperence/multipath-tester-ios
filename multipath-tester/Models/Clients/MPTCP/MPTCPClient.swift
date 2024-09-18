//
//  MPTCPClient.swift
//  test-mptcp
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import Foundation
import SwiftUI
import Alamofire

struct MultipathMode: Option{
    typealias V = URLSessionConfiguration.MultipathServiceType
    
    var name: String = "Multipath mode"
    
    var value: ContainerValue = ContainerValue(wrapped: V.none)
    var values = V.allCases.map{ v in
        ContainerValue(wrapped: v)
    }
    
    init(value: V) {
        self.value = ContainerValue(wrapped: value)
    }
    
    func apply(client: URLSessionClient) {
        var client = client
        let conf = URLSessionConfiguration.default
        conf.multipathServiceType = value.wrapped as! URLSessionConfiguration.MultipathServiceType
        client.session = URLSession(configuration: conf)
    }
    
    func apply(client: AlamofireClient) {
        var client = client
        let conf = URLSessionConfiguration.default
        conf.multipathServiceType = value.wrapped as! URLSessionConfiguration.MultipathServiceType
        client.session = Session(configuration: conf)
    }
    
    func apply(client: MPTCPClientNetwork) {
        var client = client
        switch value.wrapped as! URLSessionConfiguration.MultipathServiceType {
            case .none:
                client.params.multipathServiceType = .disabled
            case .handover:
                client.params.multipathServiceType = .handover
            case .interactive:
                client.params.multipathServiceType = .interactive
            case .aggregate:
                client.params.multipathServiceType = .aggregate
            @unknown default:
                fatalError()
        }
    }
    
    func apply(client: QuicheClient) {
        fatalError()
    }
}

protocol MPTCPClient: MultipathClient, Identifiable{
    var name: String { get }
    var id: String { get }
    func fetch(url: URL) async throws -> Data
}

extension MPTCPClient{
    var transfers: [TransferWrapper]{
        MPTCPTransfers.allCases.map{t in
            TransferWrapper(transfer: t)
        }
    }
}

struct MPTCP{
    static let clients = [
        ContainerClient(client: URLSessionClient()),
        ContainerClient(client: AlamofireClient()),
        ContainerClient(client: MPTCPClientNetwork())
    ]
}
