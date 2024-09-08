//
//  TransferComponent.swift
//  mptcp-example
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import SwiftUI

struct TransferSelectionView: View {
    
    var transfers: [TransferWrapper]
    @State private var transferWrapper: TransferWrapper
    @Binding var transfer: any Transfer
    let update: () -> Void
    
    init(transfers: [any Transfer], transfer: Binding<any Transfer>, update: @escaping () -> Void) {
        self.transfers = transfers.map{ t in TransferWrapper(transfer: t) }
        self._transfer = transfer
        self.transferWrapper = TransferWrapper(transfer: transfer.wrappedValue)
        self.update = update
    }
    
    var body: some View {
        Picker("Transfer type", selection: $transferWrapper){
            ForEach(transfers){ transfer in
                Text(transfer.transfer.name).tag(transfer)
            }
        }
        //.pickerStyle(.segmented)
        .onChange(of: transferWrapper) {
            transfer = transferWrapper.transfer
            update()
        }
    }
}

#Preview {
    TransferSelectionView(transfers: MPTCPTransfers.allCases, transfer: .constant(MPTCPTransfers.check)){}
}
