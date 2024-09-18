//
//  MPTCPClient.swift
//  test-mptcp
//
//  Created by Anthony Doeraene on 31/07/2024.
//

import Foundation
import Alamofire

struct AlamofireClient : MPTCPClient{
    
    var name: String = "AlamofireClient"
    var id: String { name }
    var transfer: TransferWrapper = TransferWrapper(transfer: MPTCPTransfers.check)
    
    var options: [any Option] = [MultipathMode(value: .none)]
    
    var session: Session = Session.default
    
    func fetch(url: URL) async throws -> Data {
        options.forEach{ option in
            option.apply(client: self)
        }
        // get a shorter description to know if we are using mptcp
        let headers: HTTPHeaders = [
            "User-Agent": "curl/7.54.1",
        ]
        let response = await withCheckedContinuation{ continuation in
            session.request(url, headers: headers).responseData{ response in
                continuation.resume(returning: response)
            }
        }
        guard let data = response.value else {
            throw RequestError.fetchingError
        }
        return data
    }
}


