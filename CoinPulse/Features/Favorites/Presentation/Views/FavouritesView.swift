//  FavouritesViewController.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 2025‑07‑17

import UIKit
import SwiftUI
import Combine

final class FavouritesViewController: UITableViewController {
    
    private let favVM        = FavouritesViewmodel()
    private var cancellables = Set<AnyCancellable>()
    
    init() { super.init(style: .insetGrouped) }
    required init?(coder: NSCoder) { super.init(coder: coder) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        tableView.contentInsetAdjustmentBehavior = .never
        
        tableView.backgroundColor = .clear
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rowHeight = 66
        tableView.separatorInset = .init(top: 0, left: 16, bottom: 0, right: 16)
        tableView.sectionHeaderTopPadding = 0
        
        favVM.$favourites
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in self?.tableView.reloadData() }
            .store(in: &cancellables)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        favVM.fetchFavourites()
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack{
                Text("Favourites")
                    .font(.title2.weight(.bold))
                
                Spacer()
            }
            
            HStack{
                Text("Total: \(favVM.favourites.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
            }
            
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    override func tableView(_ tableView: UITableView,
                            viewForHeaderInSection section: Int) -> UIView? {
        let host = UIHostingController(rootView: headerView)
        host.view.backgroundColor = .clear
        
        return host.view
    }
    
    override func tableView(_ tableView: UITableView,
                            heightForHeaderInSection section: Int) -> CGFloat {
        UIHostingController(rootView: headerView)
            .sizeThatFits(
                in: CGSize(width: view.bounds.width,
                           height: .greatestFiniteMagnitude)
            ).height
    }
    
    override func tableView(_: UITableView,
                            numberOfRowsInSection _: Int) -> Int {
        favVM.favourites.count
    }
    
    override func tableView(_ tv: UITableView,
                            cellForRowAt indexPath: IndexPath)
    -> UITableViewCell
    {
        let coin = favVM.favourites[indexPath.row]
        let cell = tv.dequeueReusableCell(withIdentifier: "Cell",
                                          for: indexPath)
        
        if #available(iOS 16.0, *) {
            cell.contentConfiguration = UIHostingConfiguration { [weak self] in
                CoinRow(rank: indexPath.row + 1,
                        coin: coin,
                        isFavourite: true) {
                    self?.favVM.toggle(coin)
                }
            }
            .margins(.all, 0)
            cell.accessoryType = .none
        } else {
            var cfg = cell.defaultContentConfiguration()
            cfg.text = coin.symbol ?? "--"
            cfg.secondaryText = coin.price ?? "--"
            cell.contentConfiguration = cfg
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView,
                            didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let uuid = favVM.favourites[indexPath.row].uuid else { return }
        
        let details = UIHostingController(rootView: CoinDetailsScreen(uuid: uuid))
        pushWithTransition(details, subtype: .fromRight)
    }
    
    override func tableView(_ tableView: UITableView,
                            trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration?
    {
        let coin = favVM.favourites[indexPath.row]
        let action = UIContextualAction(style: .destructive,
                                        title: "Unfavourite") {
            [weak self] _, _, completion in
            self?.favVM.toggle(coin)
            completion(true)
        }
        action.backgroundColor = .systemRed
        action.image = UIImage(systemName: "star.slash")
        return UISwipeActionsConfiguration(actions: [action])
    }
    
    private func pushWithTransition(
        _ vc: UIViewController,
        duration: CFTimeInterval = 0.35,
        type: CATransitionType = .moveIn,
        subtype: CATransitionSubtype = .fromRight
    ) {
        let t = CATransition()
        t.duration = duration
        t.type     = type
        t.subtype  = subtype
        t.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        navigationController?.view.layer.add(t, forKey: kCATransition)
        navigationController?.pushViewController(vc, animated: false)
    }
}
