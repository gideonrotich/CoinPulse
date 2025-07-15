//
//  CoinsUseCase.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

struct CoinsUseCase {
    let coinsRepository: CoinsProtocol
    
    init(
        coinsRepository: CoinsProtocol)
    {
        self.coinsRepository = coinsRepository
    }
    func executeGetCoins(limit: String, offset: String) async -> Result<CoinsModel, APICallError>{
        return await coinsRepository.getCoins(limit: limit, offset: offset)
    }
    
    func executeGetCoinDetail(uuid: String, timePeriod: String) async -> Result<CoinDetailsResponse, APICallError>{
        return await coinsRepository.getCoinDetails(uuid: uuid, timePeriod: timePeriod)
    }
    
    func executeGetTags() async -> Result<TagDetailsResponse, APICallError>{
        return await coinsRepository.getTags()
    }
    
    func executeGetTrendingCoins() async -> Result<TrendingCoinResponse, APICallError>{
        return await coinsRepository.getTrendingCoins()
    }
}
