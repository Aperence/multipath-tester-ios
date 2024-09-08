//
//  Measures.swift
//  mptcp-example
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import Foundation
 
struct Measure: Identifiable, Codable {
    var id = UUID()
    var transfer: any Transfer
    var date = Date()
    var mode: URLSessionConfiguration.MultipathServiceType = .none {
        didSet{
            client.mode = mode
        }
    }
    
    var measures = [UInt64]()
    private var containerClient: ContainerClient
    
    var client: any MultipathClient {
        get{
            containerClient.client
        }
        set{
            containerClient.client = newValue
        }
    }
    
    init(mode: URLSessionConfiguration.MultipathServiceType = .none, measures: [UInt64] = [], client: any MultipathClient = Multipath.clients[0].client) {
        self.mode = mode
        self.measures = measures
        self.containerClient = ContainerClient(client: client)
        self.transfer = client.transfers[0]
    }
    
    /*
      Return the estimated bandwith in Mbps according to the response time in ms
     */
    func bandwidth(for response_time: UInt64) -> Double{
        return Double(transfer.size) / Double(response_time) / 1000
    }
    
    func bandwidth(for response_time: Double) -> Double{
        return Double(transfer.size) / response_time / 1000
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, client, transfer, measures
    }
    
    enum ClientKeys: String, CodingKey {
        case name, mode
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date.timeIntervalSince1970, forKey: .date)
        try container.encode(measures, forKey: .measures)
        try container.encode(transfer.name, forKey: .transfer)
        
        var clientInfo = container.nestedContainer(keyedBy: ClientKeys.self, forKey: .client)
        try clientInfo.encode(client.name, forKey: .name)
        try clientInfo.encode(client.mode.name, forKey: .mode)
        
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        measures = try container.decode([UInt64].self, forKey: .measures)
        
        let clientInfo = try container.nestedContainer(keyedBy: ClientKeys.self, forKey: .client)
        let clientName = try clientInfo.decode(String.self, forKey: .name)
        let containerClientOptional = Multipath.clients.filter{c in
            c.client.name == clientName
        }.first
        guard let containerClientOptional else {
            fatalError("Unknown client in data file")
        }
        containerClient = containerClientOptional
        
        let modeName = try clientInfo.decode(String.self, forKey: .mode)
        switch modeName{
            case "None":
                mode = .none
            case "Handover":
                mode = .handover
            case "Interactive":
                mode = .interactive
            case "Aggregate":
                mode = .aggregate
            default:
                fatalError("Unknown")
        }
        
        let transferName = try container.decode(String.self, forKey: .transfer)
        transfer = containerClient.client.transfers.filter{ t in
            t.name == transferName
        }.first!
    }
}

