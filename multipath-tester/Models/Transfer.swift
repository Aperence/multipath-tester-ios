//
//  Transfers.swift
//  mptcp-example
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import Foundation

protocol Transfer: CaseIterable, Identifiable, Codable, Hashable{
    var id: String  { get }
    
    var name: String { get }
    var url: URL { get }
    
    // size of download in bits
    var size: Int { get }
}

extension Transfer{
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

struct TransferWrapper: Identifiable, Equatable, Hashable{
    static func == (lhs: TransferWrapper, rhs: TransferWrapper) -> Bool {
        lhs.transfer.id == rhs.transfer.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(transfer.id)
    }
    
    var id: String  {
        transfer.id
    }
    
    var transfer: any Transfer
}
