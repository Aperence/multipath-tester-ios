//
//  QuicClient.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 08/09/2024.
//

import Foundation

protocol QuicClient: MultipathClient, Identifiable{
    var name: String { get }
    var id: String { get }
    var mode: URLSessionConfiguration.MultipathServiceType{
        set get
    }
    func fetch(url: URL) async throws -> Data
}

extension QuicClient{
    var transfers: [TransferWrapper]{
        QuicTransfer.allCases.map{t in
            TransferWrapper(transfer: t)
        }
    }
}

struct Quic{
    static let clients = [
        ContainerClient(client: QuicheClient())
    ]
}
