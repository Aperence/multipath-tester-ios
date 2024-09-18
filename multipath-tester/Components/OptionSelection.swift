//
//  OptionSelection.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 18/09/2024.
//

import SwiftUI

struct OptionSelection: View{
    @Binding var option: any Option
    
    var body: some View {
        Section(option.name){
            HStack{
                Picker("Value", selection: $option.value) {
                    ForEach(option.values){ val in
                        Text(val.wrapped.name).tag(val)
                    }
                }
            }
            Text(option.value.wrapped.description)
        }
    }
}

#Preview {
    OptionSelection(option: .constant(MultipathMode(value: .none)))
}
