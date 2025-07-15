//
//  FavoriteProtocol.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

protocol FavoriteProtocol{
    func fetchFavourites() -> [Coin]
    func saveCoin(coin: Coin)
    func deleteCoin(coin: Coin)
}
