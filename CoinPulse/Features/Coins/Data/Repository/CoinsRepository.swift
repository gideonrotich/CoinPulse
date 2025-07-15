//
//  CoinsRepository.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

struct CoinsRepository: CoinsProtocol{
    
    static let shared =  CoinsRepository()
    let coinsDataSource = CoinsDataSource()
    
    func getCoins(limit: String, offset: String) async -> Result<CoinsModel, APICallError> {
        
        let results = await coinsDataSource.getCoins(limit: limit, offset: offset)
        
        switch results {
        case .success(let responseModel):
            
            print("DEBUG: Successfully fetched coins")
            return .success(responseModel)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getCoinDetails(uuid: String, timePeriod: String) async -> Result<CoinDetailsResponse, APICallError> {
        let results = await coinsDataSource.getCoinDetails(uuid: uuid, timePeriod: timePeriod)
        
        switch results {
        case .success(let responseModel):
            
            print("DEBUG: Successfully fetched coin detail")
            return .success(responseModel)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getTags() async -> Result<TagDetailsResponse, APICallError> {
        let results = await coinsDataSource.getTags()
        
        switch results {
        case .success(let responseModel):
            
            print("DEBUG: Successfully fetched tags")
            return .success(responseModel)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func getTrendingCoins() async -> Result<TrendingCoinResponse, APICallError> {
        let results = await coinsDataSource.getTrendingCoins()
        
        switch results {
        case .success(let responseModel):
            
            print("DEBUG: Successfully fetched trending coins")
            return .success(responseModel)
        case .failure(let error):
            return .failure(error)
        }
    }
}
