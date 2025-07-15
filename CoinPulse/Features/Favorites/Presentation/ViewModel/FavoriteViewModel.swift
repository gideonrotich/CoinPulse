//
//  FavoriteViewModel.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation
import Combine

@MainActor
class FavouritesViewmodel: ObservableObject {
    private let favoriteUseCases =
    FavoriteUseCase(favoriteRepository: FavoritesRepository.shared)
    
    @Published private(set) var favourites: [Coin] = []
    
    @discardableResult
    func fetchFavourites() -> [Coin] {
        favourites = favoriteUseCases.executeFetchFavorites()
        return favourites
    }
    
    func saveCoin(coin: Coin) {
        favoriteUseCases.executeSaveCoin(coin: coin)
        fetchFavourites()
    }
    
    func deleteCoin(coin: Coin) {
        favoriteUseCases.executeDeleteCoin(coin: coin)
        fetchFavourites()
    }
    
    func toggle(_ coin: Coin) {
        contains(coin) ? deleteCoin(coin:coin) : saveCoin(coin:coin)
    }
    
    func contains(_ coin: Coin) -> Bool {
        favourites.contains { $0.uuid == coin.uuid }
    }
    
}
