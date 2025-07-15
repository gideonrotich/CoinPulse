//  HomeViewController.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.

import UIKit
import SwiftUI
import Combine
import Charts

final class HomeViewController: UITableViewController {
    
    private var coins: [Coin] = []
    
    private let viewModel    = HomeViewModel()
    private let favouritesVM = FavouritesViewmodel()
    private let sortingModel = SortingModel()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let pageSize = 20
    private var offset   = 0
    private var isLoading = false
    private var fetchCancellable: AnyCancellable?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.contentInsetAdjustmentBehavior = .never
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 66
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.backgroundColor = .systemBackground
        
        tableView.tableHeaderView = makeHeader()
        favouritesVM.fetchFavourites()
        bindSorting()
        fetchData()
        fetchTrending()
    }
    
    private func fetchTrending() {
        Task {
            _ = await viewModel.fetchTrendingCoins()
            await MainActor.run { tableView.tableHeaderView = makeHeader() }
        }
    }
    
    private func fetchData() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            let new = await viewModel.fetchData(limit: "\(pageSize)", offset: "\(offset)")
            await MainActor.run {
                self.coins.append(contentsOf: new)
                self.applySort()
                self.tableView.reloadData()
                self.offset += self.pageSize
                self.isLoading = false
            }
        }
    }
    
    private func makeHeader() -> UIView {
        let trending = viewModel.trendingCoinsResponse?.data?.coins ?? []
        
        weak var weakSelf = self
        
        let root = VStack(alignment: .leading, spacing: 14) {
            
            HomeTopBar(
                onSearch:       {  },
                onNotifications:{ },
                onCandy:        {  }
            )
            
            if !trending.isEmpty {
                TrendingCarousel(
                    coins: trending,
                    onAllCategories: { },
                    onSelect: { coin in
                        guard let uuid = coin.uuid,
                              let self = weakSelf else { return }
                        let vc = UIHostingController(rootView: CoinDetailsScreen(uuid: uuid))
                        self.pushWithTransition(vc, subtype: .fromRight)
                    })
            }
            
            Text("Top 100 Coins")
                .font(.system(size: 15, weight: .semibold))
                .padding(.horizontal, 24)
            
            ListHeaderRow(model: sortingModel)
        }
        
        let host = UIHostingController(rootView: root)
        host.view.backgroundColor = .clear
        let size = host.sizeThatFits(
            in: CGSize(width: view.bounds.width,
                       height: .greatestFiniteMagnitude))
        host.view.frame = .init(origin: .zero, size: size)
        return host.view
    }
    
    private func bindSorting() {
        sortingModel.$descriptor
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.applySort()
                self?.tableView.tableHeaderView = self?.makeHeader()
            }
            .store(in: &cancellables)
    }
    
    private func applySort() {
        let d = sortingModel.descriptor
        coins.sort { lhs, rhs in
            func val(_ c: Coin) -> Double {
                switch d.key {
                case .price:     return c.price?.double      ?? 0
                case .marketCap: return c.marketCap?.double  ?? 0
                case .change24h: return c.change?.double     ?? 0
                }
            }
            return d.ascending ? val(lhs) < val(rhs) : val(lhs) > val(rhs)
        }
        tableView.reloadData()
    }
   
    override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        coins.count
    }
    
    override func tableView(_ tv: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let coin  = coins[indexPath.row]
        let isFav = favouritesVM.contains(coin)
        let cell  = tv.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        if #available(iOS 16.0, *) {
            cell.contentConfiguration = UIHostingConfiguration { [weak self] in
                CoinRow(rank: indexPath.row + 1,
                        coin: coin,
                        isFavourite: isFav) {
                    self?.toggleFavourite(coin)
                }
            }
            cell.accessoryType = .none
        } else {
            var cfg = cell.defaultContentConfiguration()
            cfg.text = "\(indexPath.row + 1). \(coin.symbol ?? "--")"
            cfg.secondaryText = "$\(coin.price ?? "--")"
            cell.contentConfiguration = cfg
        }
        return cell
    }
    
    override func tableView(_ tv: UITableView, didSelectRowAt indexPath: IndexPath) {
        tv.deselectRow(at: indexPath, animated: true)
        guard let uuid = coins[indexPath.row].uuid else { return }
        
        let vc = UIHostingController(rootView: CoinDetailsScreen(uuid: uuid))
        pushWithTransition(vc, subtype: .fromRight)
    }
    
    override func tableView(_ tv: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration?
    {
        let coin   = coins[indexPath.row]
        let isFav  = favouritesVM.contains(coin)
        
        let action = UIContextualAction(style: .normal,
                                        title: isFav ? "Unfavourite" : "Favourite") {
            [weak self] _, _, done in
            self?.toggleFavourite(coin)
            self?.tableView.reloadRows(at: [indexPath], with: .automatic)
            done(true)
        }
        action.backgroundColor = isFav ? .systemRed : .systemGreen
        action.image = UIImage(systemName: isFav ? "star.slash" : "star")
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.contentOffset.y >
                scrollView.contentSize.height - scrollView.frame.height * 2 else { return }
        
        fetchCancellable?.cancel()
        fetchCancellable = Just(())
            .delay(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.fetchData() }
    }
    
    private func toggleFavourite(_ coin: Coin) {
        favouritesVM.toggle(coin)
        tableView.reloadData()
    }
    
    private func pushWithTransition(
        _ vc: UIViewController,
        duration: CFTimeInterval = 0.35,
        type: CATransitionType = .moveIn,
        subtype: CATransitionSubtype = .fromRight
    ) {
        let t = CATransition()
        t.duration = duration
        t.type = type
        t.subtype = subtype
        t.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        navigationController?.view.layer.add(t, forKey: kCATransition)
        navigationController?.pushViewController(vc, animated: false)
    }
}

