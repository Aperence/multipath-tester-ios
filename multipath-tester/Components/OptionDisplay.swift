//
//  OptionsDisplay.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 18/09/2024.
//

import SwiftUI

import SwiftUI

struct OptionDisplay: View{
    var option: any Option
    
    var body: some View {
        HStack{
            Text(option.name)
            Spacer()
            Text(option.value.wrapped.name)
        }
    }
}

#Preview {
    OptionDisplay(option: MultipathMode(value: .none))
}
