//  CoinDetailsScreen.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 14/07/2025.
//

import SwiftUI
import Charts
import DGCharts
import SwiftTradingView

struct CoinDetailsScreen: View {
    let uuid: String
    @StateObject private var vm = HomeViewModel()
    
    @State private var period:    Period     = .h24
    @State private var chartKind: ChartKind  = .line
    
    private var coin: CoinDetail? { vm.coinDetailResponse?.data?.coin }
    
    var body: some View {
        ZStack {
            content
            overlay
        }
        .navigationTitle(coin?.name ?? "")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadEverything()
        }
    }
    
    @MainActor
    private func loadEverything() async {
        vm.state = .isLoading
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { _ = await vm.fetchTags() }
            group.addTask { _ = await vm.fetchCoinDetail(uuid: uuid,
                                                         timePeriod: period.rawValue) }
        }
        
        if case .isLoading = vm.state { vm.state = .good }
    }
}

private extension CoinDetailsScreen {
    @ViewBuilder var content: some View {
        if let coin {
            ScrollView (showsIndicators: false){
                VStack(spacing: 24) {
                    HeaderView(coin: coin)
                    PriceSection(coin: coin,
                                 chartKind: $chartKind)
                    periodPicker
                    
                    MetricsSection(coin: coin)
                    AboutSection(coin: coin)
                    
                    if !matchedTags.isEmpty {
                        TagStrip(tags: matchedTags)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
            }
        }
    }
}

private extension CoinDetailsScreen {
    @ViewBuilder var overlay: some View {
        switch vm.state {
        case .isLoading:
            ProgressView().progressViewStyle(.circular)
        case .error(let msg):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundColor(.orange)
                Text(msg)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Button("Retry") { Task { await load() } }
                    .buttonStyle(.borderedProminent)
            }
        default: EmptyView()
        }
    }
}

private extension CoinDetailsScreen {
    @MainActor
    func load() async {
        _ = await vm.fetchCoinDetail(uuid: uuid, timePeriod: period.rawValue)
    }
}

private extension CoinDetailsScreen {
    var periodMenu: some View {
        Menu {
            ForEach(Period.allCases) { p in
                Button {
                    period = p
                    Task { await load() }
                } label: {
                    Label(p.label, systemImage: period == p ? "checkmark" : "")
                }
            }
        } label: {
            Text(period.label).font(.subheadline.weight(.medium))
        }
    }
}

private extension CoinDetailsScreen {
    var periodPicker: some View {
        SegmentedPicker(selected: $period)
            .frame(height: 32)
            .onChange(of: period) { _ in
                Task { await load() }
            }
            .frame(maxWidth: 400)
    }
}


private extension CoinDetailsScreen {
    private var matchedTags: [Tag] {
        guard
            let coinTags = coin?.tags,
            let catalogue = vm.tagDetails?.data?.tags
        else { return [] }
        
        return coinTags.compactMap { slug in
            catalogue.first { $0.slug?.lowercased() == slug.lowercased() }
        }
    }
}

#Preview {
    NavigationStack {
        CoinDetailsScreen(uuid: "Qwsogvtv82FCd")
    }
}
