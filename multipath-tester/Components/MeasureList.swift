//
//  MeasureList.swift
//  multipath-tester
//
//  Created by Anthony Doeraene on 18/09/2024.
//

import SwiftUI

struct MeasureList: View{
    @Binding var measures: [Measure]
    
    var body: some View {
        ForEach($measures){ $measure in
            NavigationLink(destination: {
                MeasureView(measure: $measure)
            }, label: {
                Text("\(measure.client.name), \(measure.client.transfer.transfer.name)")
            })
        }.onDelete(perform: { indexSet in
            measures.remove(atOffsets: indexSet)
        })
    }
}
