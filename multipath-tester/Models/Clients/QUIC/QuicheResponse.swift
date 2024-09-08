//
//  QuicheResponse.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 08/09/2024.
//

import Foundation

struct QuicheResponse{
    let data: String?
    let status: Int
    let len: Int

    init(raw_response: http_response_t?){
        if let raw_response{
            status = Int(raw_response.status)
            len = Int(raw_response.len);
            if let res_unwraped = raw_response.data{
                data = String(cString: res_unwraped)
            }else{
                data = nil
            }
        }else{
            status = -1
            data = nil
            len = 0
        }
    }
}
