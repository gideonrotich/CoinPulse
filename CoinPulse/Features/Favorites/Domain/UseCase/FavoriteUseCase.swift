//
//  FavoriteUseCase.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

struct FavoriteUseCase {
    let favoriteRepository: FavoriteProtocol
    
    init(
        favoriteRepository: FavoriteProtocol)
    {
        self.favoriteRepository = favoriteRepository
    }
    func executeFetchFavorites() -> [Coin]{
        return favoriteRepository.fetchFavourites()
    }
    
    func executeSaveCoin(coin: Coin){
        return favoriteRepository.saveCoin(coin: coin)
    }
    
    func executeDeleteCoin(coin: Coin){
        return favoriteRepository.deleteCoin(coin: coin)
    }
}
