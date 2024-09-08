//
//  MultipathClient.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 08/09/2024.
//

import Foundation
import SwiftUI

protocol MultipathClient: Identifiable{
    var name: String { get }
    var id: String { get }
    var mode: URLSessionConfiguration.MultipathServiceType{
        set get
    }
    var hasMode: Bool { get }
    var transfers: [any Transfer] { get }
    func fetch(url: URL) async throws -> Data
}

struct ContainerClient: Equatable, Hashable, Identifiable{
    
    static func == (lhs: ContainerClient, rhs: ContainerClient) -> Bool {
        rhs.id == lhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var client: any MultipathClient
    var id: String { client.name }
    
    init(client: any MultipathClient) {
        self.client = client
    }
    
    enum CodingKeys: String, CodingKey {
        case name
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(client.name, forKey: .name)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let clientName = try container.decode(String.self, forKey: .name)
        switch clientName{
            case "URLSessionClient":
                self.client = URLSessionClient()
            case "AlamofireClient":
                self.client = AlamofireClient()
            default:
                fatalError("Unknown client in data file")
        }
    }
}

struct Multipath{
    static let clients = [
        ContainerClient(client: QuicheClient()),
        ContainerClient(client: URLSessionClient()),
        ContainerClient(client: AlamofireClient()),
        ContainerClient(client: MPTCPClientNetwork())
    ]
}
