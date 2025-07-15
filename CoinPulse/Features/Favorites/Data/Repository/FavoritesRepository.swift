//
//  FavoritesRepository.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

struct FavoritesRepository : FavoriteProtocol{
    static let shared =  FavoritesRepository()
    let favoritesDataSource = LocalFavouritesDataSource()
    
    func fetchFavourites() -> [Coin] {
        return favoritesDataSource.fetchFavourites()
    }
    
    func saveCoin(coin: Coin) {
        return favoritesDataSource.saveCoin(coin: coin)
    }
    
    func deleteCoin(coin: Coin) {
        return favoritesDataSource.deleteCoin(coin: coin)
    }
    
}
