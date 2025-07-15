//
//  ListHeaderRow.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct ListHeaderRow: View {
    @ObservedObject var model: SortingModel
    
    var body: some View {
        VStack {
            HStack{
                MarketsHeader(model: model)
                
                Spacer()
            }
            
            HStack(spacing: 12) {
                Text("#").frame(width: 20, alignment: .trailing)
                Text("Market Cap").frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(1)
                Text("Price").frame(width: 100, alignment: .trailing)
                Spacer().frame(width: 60)
                Text("24h %").frame(width: 60, alignment: .trailing)
            }
            .font(.caption.weight(.medium))
            .foregroundStyle(.secondary)
            .padding(.bottom, 4)
            .padding(.trailing,10)
        }
        .padding(.horizontal, 16)
    }
}
