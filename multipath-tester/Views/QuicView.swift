//
//  ContentView.swift
//  quiche-test
//
//  Created by Anthony Doeraene on 05/09/2024.
//

import SwiftUI



struct QuicView: View {
    let client = QuicheClient();
    @State private var response: Data? = nil;
    @State private var errorSaved: Error? = nil;
    @State private var fetching = false;
    @State private var urlString = QuicTransfer.quiche.rawValue;
    @FocusState private var urlFieldFocused: Bool;
    
    private var url: URL? {
        URL(string: urlString)
    }

    var body: some View {
        VStack {
            List{
                Picker("Test server", selection: $urlString){
                    ForEach(QuicTransfer.allCases){ url in
                        Text(url.rawValue).tag(url.rawValue)
                    }
                }
                TextField("URL", text: $urlString)
                    .focused($urlFieldFocused)
                    .keyboardType(.URL)
                    .textContentType(.URL)
                if let url, let host = url.host(){
                    Button("Fetch \(host)", systemImage: "dot.radiowaves.up.forward"){
                        quic_fetch()
                    }
                }
                if fetching{
                    ProgressView()
                }
                if let errorSaved {
                    Text("An error occurred: \(errorSaved.localizedDescription)")
                }else if let response{
                    HTMLStringView(htmlContent: String(data: response, encoding: .utf8)!)
                        .frame(maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, minHeight: 600)
                        .padding(0)
                }
            }
        }
        .padding()
    }

    func quic_fetch(){
        if fetching{
            // don't make twice a request at sale time
            return
        }
        Task{
            response = nil
            fetching = true
            defer {
                fetching = false
            }
            do{
                response = try await client.fetch(url: url!)
                errorSaved = nil
            }catch{
                errorSaved = error
            }
        }
    }
}

#Preview {
    QuicView()
}
