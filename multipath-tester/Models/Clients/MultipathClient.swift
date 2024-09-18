//
//  MultipathClient.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 08/09/2024.
//

import Foundation
import SwiftUI

protocol Describable: CaseIterable, Hashable{
    var name: String { get }
    var description: String { get }
}

struct ContainerValue: Equatable, Hashable, Identifiable{
    
    static func == (lhs: ContainerValue, rhs: ContainerValue) -> Bool {
        let ret = rhs.wrapped.description == lhs.wrapped.description && lhs.wrapped.name == rhs.wrapped.name
        return ret
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var wrapped: any Describable
    var id: String { wrapped.name }
}

protocol Option: Hashable, Equatable{
    associatedtype V: Describable
    var value: ContainerValue { get set }
    var values: [ContainerValue] { get }
    var name: String { get }
    var id: String { get }
    
    // apply a visitor
    func apply(client: URLSessionClient)
    func apply(client: AlamofireClient)
    func apply(client: MPTCPClientNetwork)
    func apply(client: QuicheClient)
}

extension Option{
    var id: String{
        name
    }
}

protocol MultipathClient: Identifiable{
    var name: String { get }
    var id: String { get }
    var options: [any Option] { get set }
    var transfers: [TransferWrapper] { get }
    var transfer: TransferWrapper { get set }
    func fetch(url: URL) async throws -> Data
}

struct ContainerClient: Equatable, Hashable, Identifiable{
    
    static func == (lhs: ContainerClient, rhs: ContainerClient) -> Bool {
        rhs.client.id == lhs.client.id &&
        rhs.client.transfer.transfer.name == lhs.client.transfer.transfer.name && rhs.client.options.allSatisfy{ o in
            let o2 = lhs.client.options.filter{ o2 in o2.name == o.name }.first
            guard let o2 else { return false }
            return o2.value == o.value
        }
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


