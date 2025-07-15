//
//  HeaderView.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct HeaderView: View {
    let coin: CoinDetail
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack(spacing: 6) {
            
            Button {
                dismiss()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.primary)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
            }
            
            RemoteIcon(url: coin.iconURL)
                .frame(width: 34, height: 34)
                .padding(.horizontal,12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(coin.name ?? "--")
                    .font(.title3.weight(.bold))
                    .lineLimit(1)
                Text(coin.symbol ?? "")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let rank = coin.rank {
                Text("#\(rank)")
                    .font(.footnote.weight(.medium))
                    .padding(.vertical, 4)
                    .padding(.horizontal, 10)
                    .background(Color(.systemGray6), in: Capsule())
            }
        }
    }
}

private struct RemoteIcon: View {
    let url: String?
    var body: some View {
        CircularImageView(
            url: url,
            size: CGSize(width: 40, height: 40)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
