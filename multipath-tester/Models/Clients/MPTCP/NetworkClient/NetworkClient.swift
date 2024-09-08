//
//  MPTCPClient.swift
//  mptcp-network
//
//  Created by Anthony Doeraene on 07/08/2024.
//

import Foundation
import Network

public class NetworkClient{
    var connection: NWConnection
    var queue: DispatchQueue
    var ready: Bool = false
    
    public init(to server: NWEndpoint, params: NWParameters = .tls) throws{
        queue = DispatchQueue(label: "MPTCP client Queue")
        let semaphore = DispatchSemaphore(value: 0)

        connection = NWConnection(to: server, using: params)
        
        connection.stateUpdateHandler = { (newState) in
            switch (newState){
                case .waiting( _):
                    print("Waiting")
                case .ready:
                    semaphore.signal()
                case .failed( _):
                    print("Failed")
                default:
                    break
            }
        }
        
        connection.start(queue: queue)
        let res = semaphore.wait(timeout: DispatchTime.now().advanced(by: DispatchTimeInterval.seconds(3)))
        if res == .timedOut{
            throw RequestNetworkError.failedToConnect
        }
    }
    
    func receive(onData: @escaping (Data) -> Void, onComplete: @escaping () -> Void){
        connection.receive(minimumIncompleteLength: 0, maximumLength: 1024) { (content, context, isComplete, error) in
            if let _ = error{
                onComplete()
            }
            if let content{
                onData(content)
            }
            if (isComplete){
                onComplete()
            }else{
                self.receive(onData: onData, onComplete: onComplete)
            }
        }
    }
    
    public func get(path: String) async throws -> HTTPResponse{
        let content = HTTPRequest(path: path).set_header(for: "User-Agent", value: "curl/1.0.0").to_bytes()
        connection.send(content: content, completion: .contentProcessed({ (error) in
            if let error = error{
                print("Send error: \(error)")
            }
        }))
        
        var ret = Data()
        
        await withCheckedContinuation{ continuation in
            receive{ data in
                ret.append(data)
            } onComplete: {
                continuation.resume()
            }
        }
        
        return try HTTPResponse(from: ret)
    }
}
