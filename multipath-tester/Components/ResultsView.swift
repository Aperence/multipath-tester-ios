//
//  ResultsComponent.swift
//  mptcp-example
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import SwiftUI

struct ResultsView: View {
    
    var using_mptcp: Bool
    var transfer: any Transfer
    var response_time: UInt64
    var response_time_str: String {
        "Response time: \(response_time) ms"
    }
    var bandwidth: Double {
        Double(transfer.size) / Double(response_time) / 1000
    }
    var bandwidth_str: String {
        String(format: "Bandwidth: %.2f mbps", bandwidth)
    }
    
    var body: some View {
        if transfer as! MPTCPTransfers == MPTCPTransfers.check{
            if using_mptcp{
                HStack{
                    Image(systemName: "checkmark.seal.fill").foregroundColor(.green)
                    Text("You are using MPTCP")
                }.font(.title2)
            }else{
                HStack{
                    Image(systemName: "xmark.seal.fill").foregroundColor(.red)
                    Text("You aren't using MPTCP")
                }.font(.title2)
            }
        }
        Text(response_time_str)
        if transfer as! MPTCPTransfers != MPTCPTransfers.check{
            Text(bandwidth_str).font(.title3)
        }
    }
}

#Preview {
    ResultsView(using_mptcp: true, transfer: MPTCPTransfers.check, response_time: 1000)
}
