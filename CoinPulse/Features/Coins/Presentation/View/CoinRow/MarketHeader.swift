//
//  MarketHeader.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct MarketsHeader: View {
    @ObservedObject var model: SortingModel
    
    var body: some View {
        HStack(spacing: 12) {
            SortButton(label: "Market cap", key: .marketCap, model: model)
            SortButton(label: "Price",      key: .price,      model: model)
            SortButton(label: "24h %",      key: .change24h,  model: model)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
}
