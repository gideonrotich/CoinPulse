//
//  PriceSection.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct PriceSection: View {
    let coin: CoinDetail
    @Binding var chartKind: ChartKind
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            priceRow
            chartPicker
            chartView
        }
        .padding(20)
        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 20))
    }
    
    private var priceRow: some View {
        let price  = coin.price?.double ?? 0
        let change = coin.change?.double ?? 0
        let accent = change >= 0 ? Color.green : .red
        
        return HStack(alignment: .firstTextBaseline) {
            Text("$\(price.formatted(.number.precision(.fractionLength(0...2))))")
                .font(.title2.weight(.bold))
            
            Spacer(minLength: 8)
            
            HStack(spacing: 4) {
                Image(systemName: change >= 0 ? "arrow.up" : "arrow.down")
                Text(String(format: "%.2f%%", abs(change)))
            }
            .font(.subheadline.weight(.semibold))
            .foregroundColor(accent)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(accent.opacity(0.12), in: Capsule())
        }
    }
    
    private var chartPicker: some View {
        Picker("", selection: $chartKind) {
            ForEach(ChartKind.allCases) { kind in
                Text(kind.label).tag(kind)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private var chartView: some View {
        let spark = coin.sparkline?.compactMap { $0?.double } ?? []
        let negative = (coin.change?.double ?? 0) < 0
        
        return Group {
            if chartKind == .line {
                LineChartView(sparklineData: spark,
                              negativeChange: negative)
            } else {
                
                let spark: [SparkPoint] = sparklineToSparkPoints(
                    sparkline: spark,
                    startTime: Date().addingTimeInterval(-Double(coin.sparkline?.count ?? 0) * 60)
                )
                
                TradingChart(spark: spark)
                    .frame(height: 80)
                    .padding(.horizontal, 0)
                    .padding(.vertical, 0)
                
            }
        }
        .frame(height: 210)
    }
}

func sparklineToSparkPoints(
    sparkline: [Double],
    startTime: Date,
    interval: TimeInterval = 60
) -> [SparkPoint] {
    guard sparkline.count >= 2 else { return [] }
    
    var points: [SparkPoint] = []
    
    for i in 1..<sparkline.count {
        let open  = sparkline[i - 1]
        let close = sparkline[i]
        let high  = max(open, close) * (1 + Double.random(in: 0...0.005))
        let low   = min(open, close) * (1 - Double.random(in: 0...0.005))
        let volume = Double.random(in: 1_000...5_000)
        
        let timestamp = startTime.addingTimeInterval(Double(i) * interval)
        
        points.append(
            SparkPoint(timestamp: timestamp,
                       open: open,
                       high: high,
                       low: low,
                       close: close,
                       volume: volume)
        )
    }
    return points
}


enum ChartKind: String, CaseIterable, Identifiable {
    case line, candle
    var id: Self { self }
    var label: String { self == .line ? "Line" : "Trading View" }
}

