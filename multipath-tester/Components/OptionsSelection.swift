//
//  OptionSelection.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 18/09/2024.
//

import SwiftUI

struct OptionsSelection: View{
    @Binding var client: any MultipathClient
    
    var body: some View {
        ForEach($client.options, id: \.id){ $option in
            OptionSelection(option: $option)
        }
    }
}

#Preview {
    OptionsSelection(client: .constant(URLSessionClient()))
}
