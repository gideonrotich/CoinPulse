//
//  CoinRow.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct CoinRow: View {
    let rank: Int
    let coin: Coin
    let isFavourite: Bool
    let onToggleFavourite: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Text("\(rank)")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .frame(width: 20, alignment: .trailing)
            
            CircularImageView(
                url: coin.iconURL,
                size: CGSize(width: 35, height: 35)
            )
            
            VStack(alignment: .leading, spacing: 2) {
                Text(coin.symbol ?? "")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                if let mCap = coin.marketCap?.double {
                    Text("$\(mCap.abbreviated())")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                } else {
                    Text("--").font(.caption2).foregroundStyle(.secondary)
                }
            }
            
            Spacer(minLength: 0)
            
            if let price = coin.price?.double {
                Text("$\(price.formatted(.number.precision(.fractionLength(0...2))))")
                    .font(.subheadline)
                    .frame(width: 100, alignment: .trailing)
            } else {
                Text("--").frame(width: 100, alignment: .trailing)
            }
            
            Spacer()
            
            if #available(iOS 16.0, *) {
                let changeVal = coin.change?.double ?? 0
                let spark = coin.sparkline?.compactMap { $0.double } ?? []
                CoinStatView(
                    change: changeVal,
                    sparkline: spark,
                    accentColor: changeVal >= 0 ? .green : .red
                )
                .frame(width: 60)
                .frame(height: 10)
            } else {
                Text("--").frame(width: 60)
            }
            Spacer()
            
        }
        .padding(.vertical, 6)
    }
}
