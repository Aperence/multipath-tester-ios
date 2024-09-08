//
//  ClientComponent.swift
//  mptcp-example
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import SwiftUI

struct ClientSelectionView: View {
    let mptcpOnly: Bool
    private var clients: [ContainerClient]
    @State private var clientContainer: ContainerClient = MPTCP.clients[0]
    @Binding var client: any MultipathClient
    let update: () -> Void
    
    init(client: Binding<any MultipathClient>, update: @escaping () -> Void, mptcpOnly: Bool = false) {
        self.mptcpOnly = mptcpOnly
        if self.mptcpOnly{
            self.clients = MPTCP.clients
        }else{
            self.clients = Multipath.clients
        }
        self.clientContainer = self.clients[0]
        self.update = update
        self._client = client
    }
    
    var body: some View {
        Picker("Clients", selection: $clientContainer){
            ForEach(clients){ container in
                Text(container.client.name).tag(container)
            }
        }
        //.pickerStyle(.segmented)
        .onChange(of: clientContainer){
            client = clientContainer.client
            update()
        }
    }
}

#Preview {
    ClientSelectionView(client: .constant(MPTCP.clients[0].client), update: {})
}
