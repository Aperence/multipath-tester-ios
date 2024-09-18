//
//  Measures.swift
//  mptcp-example
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import Foundation
 
struct Measure: Identifiable, Codable {
    var id = UUID()
    var date = Date()
    
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
    
    init(measures: [UInt64] = [], client: any MultipathClient = Multipath.clients[0].client) {
        self.measures = measures
        self.containerClient = ContainerClient(client: client)
    }
    
    /*
      Return the estimated bandwith in Mbps according to the response time in ms
     */
    func bandwidth(for response_time: UInt64) -> Double{
        return Double(client.transfer.transfer.size) / Double(response_time) / 1000
    }
    
    func bandwidth(for response_time: Double) -> Double{
        return Double(client.transfer.transfer.size) / response_time / 1000
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, client, transfer, measures
    }
    
    enum ClientKeys: String, CodingKey {
        case name, options
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date.timeIntervalSince1970, forKey: .date)
        try container.encode(measures, forKey: .measures)
        try container.encode(client.transfer.transfer.name, forKey: .transfer)
        
        var clientInfo = container.nestedContainer(keyedBy: ClientKeys.self, forKey: .client)
        try clientInfo.encode(client.name, forKey: .name)
        var map : [String: String] = [:]
        for option in client.options{
            map[option.name] = option.value.wrapped.name
        }
        
        try clientInfo.encode(map, forKey: .options)
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
        
        let transferName = try container.decode(String.self, forKey: .transfer)
        client.transfer = containerClient.client.transfers.filter{ t in
            t.transfer.name == transferName
        }.first!
        
        let options = try clientInfo.decode([String: String].self, forKey: .options)
        var options_client: [any Option] = []
        for (key, value) in options{
            print("\(key) = \(value)")
            var option = client.options.filter{ o in
                o.name == key
            }.first!
            
            let value = option.values.filter{ v in
                v.wrapped.name == value
            }.first!
            
            option.value = value
            options_client.append(option)
        }
        client.options = options_client
    }
}

