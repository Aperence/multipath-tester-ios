//
//  MPTCPClient.swift
//  test-mptcp
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import Foundation
import SwiftUI

protocol MPTCPClient: MultipathClient, Identifiable{
    var name: String { get }
    var id: String { get }
    var mode: URLSessionConfiguration.MultipathServiceType{
        set get
    }
    func fetch(url: URL) async throws -> Data
}

extension MPTCPClient{
    var hasMode: Bool{
        true
    }
    
    var transfers: [any Transfer]{
        MPTCPTransfers.allCases
    }
}

struct MPTCP{
    static let clients = [
        ContainerClient(client: URLSessionClient()),
        ContainerClient(client: AlamofireClient()),
        ContainerClient(client: MPTCPClientNetwork())
    ]
}
