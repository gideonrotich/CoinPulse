//
//  TrendingCarousel.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct TrendingCarousel: View {
    let coins: [TrendingCoin]
    var onAllCategories: () -> Void
    var onSelect: (TrendingCoin) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            HStack {
                Text("Trending Coins")
                    .font(.system(size: 15, weight: .semibold))
                Text("🔥")
                    .font(.system(size: 13, weight: .semibold))
                
                Spacer()
                Button("All categories", action: onAllCategories)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.green)
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.green.opacity(0.5))
                    .font(.system(size: 13))
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 24) {
                    ForEach(coins, id: \.uuid) { coin in
                        TrendingCard(coin: coin) {
                            onSelect(coin)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .background(Color(.systemBackground))
    }
}

struct TrendingCard: View {
    let coin: TrendingCoin
    let onTap: () -> Void
    
    private var name: String { coin.name ?? "--" }
    private var mcap: String { (coin.marketCap?.double ?? 0).abbreviated() }
    private var change: Double { coin.change?.double ?? 0 }
    private var changeColor: Color { change >= 0 ? .green : .red }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                CircularImageView(url: coin.iconURL ?? "",
                                  size: CGSize(width: 44, height: 44))
                .cornerRadius(8)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 13))
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Text("$ \(mcap)")
                            .font(.subheadline.weight(.medium))
                        Text(String(format: "%.2f%%", change))
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(changeColor)
                    }
                }
            }
        }
        .padding(16)
        .frame(width: 210, height: 84)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture { onTap() }
    }
}


