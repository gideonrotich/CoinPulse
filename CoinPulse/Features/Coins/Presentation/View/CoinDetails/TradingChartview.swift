//
//  TradingChartview.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI
import Charts
import DGCharts
import SwiftTradingView

struct TradingCandleChart: View {
    let sparkline: [Double]
    
    private var candles: [CandleData] {
        guard sparkline.count > 3 else { return [] }
        
        let bucket = max(4, sparkline.count / 40)
        
        return stride(from: 0,
                      to: sparkline.count,
                      by: bucket).map { start in
            let end = min(start + bucket, sparkline.count)
            let slice = Array(sparkline[start..<end])
            
            let open  = slice.first!
            let close = slice.last!
            let high  = slice.max()!
            let low   = slice.min()!
            
            return CandleData(
                time:   TimeInterval(start * 600),
                open:   open,
                close:  close,
                high:   high,
                low:    low,
                volume: 0
            )
        }
    }
    
    var body: some View {
        GeometryReader { geo in
            let candleCount  = max(1, candles.count)
            let spacing: CGFloat = 1
            let width = geo.size.width
            let candleW = max(
                2,
                Int( (width - spacing * CGFloat(candleCount - 1)) / CGFloat(candleCount) )
            )
            
            TradingView(
                data: candles,
                candleWidth: CGFloat(candleW)...CGFloat(candleW),
                candleSpacing: CGFloat(spacing),
                scrollTrailingInset: 0,
                primaryContentHeight: 120,
                legendPaddingLeading: CGFloat(10),
                primaryContent: [ Candles() ],
                secondaryContent: []
            )
            
            .frame(width: width, height: geo.size.height)
        }
        .frame(height: 140)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

struct CandleChart: View {
    
    private struct Candle: Identifiable {
        let id:    Int
        let open:  Double
        let close: Double
        let high:  Double
        let low:   Double
    }
    
    let sparklineData: [Double]
    
    private var candles: [Candle] {
        guard sparklineData.count > 3 else { return [] }
        
        let chunkSize = max(4, sparklineData.count / 12)
        
        return stride(from: 0,
                      to: sparklineData.count,
                      by: chunkSize).enumerated().compactMap { idx, start in
            
            let slice = Array(sparklineData[start ..< min(start + chunkSize,
                                                          sparklineData.count)])
            
            guard let open  = slice.first,
                  let close = slice.last else { return nil }
            
            return Candle(
                id:    idx,
                open:  open,
                close: close,
                high:  slice.max() ?? open,
                low:   slice.min() ?? open
            )
        }
    }
    
    var body: some View {
        Chart(candles) { candle in
            
            RuleMark(
                x: .value("Idx", candle.id),
                yStart: .value("Low", candle.low),
                yEnd:   .value("High", candle.high)
            )
            .lineStyle(StrokeStyle(lineWidth: 1))
            .foregroundStyle(Color.primary.opacity(0.4))
            
            RectangleMark(
                x: .value("Idx", candle.id),
                yStart: .value("Open", candle.open),
                yEnd:   .value("Close", candle.close)
            )
            .cornerRadius(1)
            .foregroundStyle(candle.close >= candle.open ? .green : .red)
        }
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

public struct SparkPoint: Identifiable {
    public let id = UUID()
    public let timestamp: Date
    public let open: Double
    public let high: Double
    public let low: Double
    public let close: Double
    public let volume: Double
}

extension Array where Element == SparkPoint {
    
    func asCandleEntries() -> [CandleChartDataEntry] {
        enumerated().map { i, p in
            CandleChartDataEntry(
                x: Double(i),
                shadowH: p.high,
                shadowL: p.low,
                open: p.open,
                close: p.close,
                data: p.timestamp as NSDate
            )
        }
    }
}

final class DateAxisFormatter: NSObject, AxisValueFormatter {
    private let entries: [CandleChartDataEntry]
    private let dayFormatter: DateFormatter
    private let intradayFormatter: DateFormatter
    
    init(entries: [CandleChartDataEntry]) {
        self.entries = entries
        self.dayFormatter = .init()
        self.intradayFormatter = .init()
        dayFormatter.dateFormat = "dd MMM"
        intradayFormatter.dateFormat = "HH:mm"
    }
    
    func stringForValue(_ value: Double, axis _: AxisBase?) -> String {
        let index = Int(round(value))
        guard entries.indices.contains(index),
              let date = (entries[index].data as? NSDate) as Date? else { return "" }
        
        let span = (entries.last?.data as? NSDate)?.timeIntervalSince1970 ?? 0 -
        (entries.first?.data as? NSDate)!.timeIntervalSince1970 ?? 0
        return span < 86_400 * 2 ? intradayFormatter.string(from: date)
        : dayFormatter.string(from: date)
    }
}


struct CandleStickChartRepresentable: UIViewRepresentable {
    let candleEntries: [CandleChartDataEntry]
    
    func makeUIView(context: Context) -> CandleStickChartView {
        let chart = CandleStickChartView()
        chart.configureAppearance()
        return chart
    }
    
    func updateUIView(_ chart: CandleStickChartView, context: Context) {
        let set = CandleChartDataSet(entries: candleEntries, label: "Price")
        set.increasingColor         = .systemGreen
        set.increasingFilled        = true
        set.decreasingColor         = .systemRed
        set.decreasingFilled        = true
        set.neutralColor            = .systemGray
        set.shadowColorSameAsCandle = true
        set.drawValuesEnabled       = false
        
        chart.data = CandleChartData(dataSet: set)
        
        chart.xAxis.valueFormatter = DateAxisFormatter(entries: candleEntries)
        
        chart.notifyDataSetChanged()
    }
}

private extension CandleStickChartView {
    func configureAppearance() {
        legend.enabled             = false
        rightAxis.enabled          = false
        leftAxis.labelFont         = .systemFont(ofSize: 11, weight: .medium)
        leftAxis.labelTextColor    = .secondaryLabel
        leftAxis.gridColor         = .tertiarySystemFill
        
        xAxis.labelPosition        = .bottom
        xAxis.drawGridLinesEnabled = true
        xAxis.labelFont            = .systemFont(ofSize: 11, weight: .medium)
        xAxis.labelTextColor       = .secondaryLabel
        
        dragEnabled       = true
        scaleXEnabled     = true
        scaleYEnabled     = true
        pinchZoomEnabled  = true
        highlightPerDragEnabled = true
        autoScaleMinMaxEnabled   = false
        minOffset = 0
    }
}

public struct TradingChart: View {
    public let spark: [SparkPoint]
    
    public init(spark: [SparkPoint]) {
        self.spark = spark
    }
    
    public var body: some View {
        CandleStickChartRepresentable(candleEntries: spark.asCandleEntries())
            .frame(minHeight: 210, maxHeight: 250)
            .background(Color(.systemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(radius: 2)
            .padding(.top,10)
    }
}

#if DEBUG
struct TradingChart_Previews: PreviewProvider {
    static var previews: some View {
        let now = Date()
        var points: [SparkPoint] = []
        (0..<60).reduce(100.0) { price, i in
            let open = price
            let high = open * (1 + .random(in: 0...0.01))
            let low  = open * (1 - .random(in: 0...0.01))
            let close = Double.random(in: low...high)
            points.append(SparkPoint(timestamp: now.addingTimeInterval(Double(i) * 60),
                                     open: open, high: high, low: low, close: close,
                                     volume: .random(in: 1_000...10_000)))
            return close
        }
        
        return TradingChart(spark: points)
            .preferredColorScheme(.dark)
    }
}
#endif

