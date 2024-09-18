//
//  OptionsDisplay.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 18/09/2024.
//

import SwiftUI

import SwiftUI

struct OptionsDisplay: View{
    var client: any MultipathClient
    
    var body: some View {
        Section("Options"){
            ForEach(client.options, id: \.id){ option in
                OptionDisplay(option: option)
            }
        }
    }
}

#Preview {
    OptionsDisplay(client: URLSessionClient())
}
