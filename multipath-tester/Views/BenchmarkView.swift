//
//  BenchmarkView.swift
//  mptcp-example
//
//  Created by Anthony Doeraene on 01/08/2024.
//

import SwiftUI
import UniformTypeIdentifiers

struct BenchmarkView: View {
    @State private var showingRunBenchmark = false
    @State private var showingExport = false
    @State private var showingAlertSendData = false
    @State private var showingFailedSendingData = false
    @State private var showingSuccessSendingData = false
    @State private var errorSending: Error? = nil
    @Binding var measures: [Measure]
    @State private var newMeasure = Measure()
    @Environment(\.scenePhase) private var scenePhase
    var onSceneChange: () -> Void
    private var document: MeasurementFile {
        MeasurementFile(measurements: measures)
    }
    
    let data_server_url = ProcessInfo.processInfo.environment["UPLOAD_HOST"]!
    let path = ProcessInfo.processInfo.environment["UPLOAD_PATH"]!
    
    var body: some View {
        NavigationStack{
            List{
                ForEach($measures){ $measure in
                    NavigationLink(destination: {
                        MeasureView(measure: $measure)
                    }, label: {
                        Text("\(measure.client.name), \(measure.mode.name), \(measure.transfer.name)")
                    })
                }.onDelete(perform: { indexSet in
                    measures.remove(atOffsets: indexSet)
                })
            }.sheet(isPresented: $showingRunBenchmark, onDismiss: {
                showingRunBenchmark = false
            }, content: {
                NewBenchmarkView(measure: $newMeasure){
                    measures.insert(newMeasure, at: 0)
                    newMeasure = Measure()
                } onClosed: {
                    newMeasure = Measure()
                }
            }).toolbar{
                ToolbarItem(placement: .topBarLeading){
                    Button{
                        showingExport = true
                    } label: {
                        Label("Download measurements", systemImage: "square.and.arrow.down")
                    }
                }
                ToolbarItem(){
                    Button{
                        showingAlertSendData = true
                    } label: {
                        Label("Export data", systemImage: "square.and.arrow.up")
                    }
                }
                ToolbarItem(placement: .topBarTrailing){
                    Button{
                        showingRunBenchmark = true
                    } label: {
                        Label("Run benchmark", systemImage: "plus")
                    }
                }
            }.onChange(of: scenePhase){
                if scenePhase == .inactive { onSceneChange()}
            }.fileExporter(isPresented: $showingExport, document: document, contentType: .json, defaultFilename: "measures"){ result in
                debugPrint(result)
            }.alert("Send measurements to the remove server \(data_server_url) ?", isPresented: $showingAlertSendData) {
                Button("Cancel", role: .cancel) {}
                Button("Send measurements") {
                    do{
                        let req = try URLRequest(url: "\(data_server_url)\(path)", method: .post);
                        let task = URLSession.shared.uploadTask(with: req, from: try JSONEncoder().encode(measures)){ data, response, error in
                            if let error = error {
                                errorSending = error
                                showingFailedSendingData = true
                                return
                            }
                            
                            showingSuccessSendingData = true
                        }
                        task.resume()
                    }catch{
                        errorSending = error
                        showingFailedSendingData = true
                    }
                }
            }
            .alert("Failed to send the measurements", isPresented: $showingFailedSendingData, presenting: $errorSending) { _ in
                Button("Ok", role: .cancel) {}
            }
            .alert("Sent successfully the measurements", isPresented: $showingSuccessSendingData) {
                Button("Ok", role: .cancel) {}
            }
        }
    }
}

#Preview {
    BenchmarkView(measures: .constant([])){}
}
