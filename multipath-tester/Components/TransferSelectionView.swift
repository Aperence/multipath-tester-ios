//
//  TransferComponent.swift
//  mptcp-example
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import SwiftUI

struct TransferSelectionView: View {
    
    @Binding var client: any MultipathClient
    
    init(client: Binding<any MultipathClient>) {
        self._client = client
    }
    
    var body: some View {
        Picker("Transfer type", selection: $client.transfer){
            ForEach(client.transfers){ transfer in
                Text(transfer.transfer.name).tag(transfer)
            }
        }
        //.pickerStyle(.segmented)
    }
}

#Preview {
    TransferSelectionView(client: .constant(URLSessionClient()))
}
