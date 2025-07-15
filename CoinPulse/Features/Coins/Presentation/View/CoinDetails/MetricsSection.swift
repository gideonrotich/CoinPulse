//
//  MetricsSection.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct MetricsSection: View {
    let coin: CoinDetail
    
    private var items: [(String,String)] {
        [
            ("Market Cap",  coin.marketCap?.double?.abbreviated() ?? "--"),
            ("24h Volume",  coin.the24HVolume?.double?.abbreviated() ?? "--"),
            ("Circulating", coin.supply?.circulating?.double?.abbreviated() ?? "--"),
            ("Max Supply",  coin.supply?.max?.double?.abbreviated() ?? "--")
        ]
    }
    
    var body: some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible(), spacing: 12), count: 2),
                  spacing: 12) {
            ForEach(items, id: \.0) { item in
                MetricTile(title: item.0, value: item.1)
            }
        }
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.headline.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 14))
    }
}

struct AboutSection: View {
    let coin: CoinDetail
    var body: some View {
        if let html = coin.description, !html.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("About \(coin.name ?? "")")
                    .font(.headline)
                Text(attributed(html))
                    .font(.callout)
            }
            .padding(10)
            .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 20))
        }
    }
    
    private func attributed(_ html: String) -> AttributedString {
        (try? AttributedString(markdown: html)) ??
        AttributedString(stringLiteral: html.replacingOccurrences(of: "<[^>]+>",
                                                                  with: " ",
                                                                  options: .regularExpression))
    }
}
