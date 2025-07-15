//
//  CoinsViewModel.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//
import Foundation
import Combine

@MainActor
class HomeViewModel: ObservableObject {
    
    @Published var state: FetchState = .good
    @Published var coinsResponse: CoinsModel?
    @Published var coinDetailResponse: CoinDetailsResponse?
    @Published var tagDetails: TagDetailsResponse?
    @Published var trendingCoinsResponse: TrendingCoinResponse?
    
    private let coinsUseCases = CoinsUseCase(coinsRepository: CoinsRepository.shared)
    
    func fetchData(limit: String, offset: String) async -> [Coin] {
        state = .isLoading
        
        let result = await coinsUseCases.executeGetCoins(limit: limit, offset: offset)
        
        switch result {
        case .success(let responseEntity):
            coinsResponse = responseEntity
            state = .good
            return responseEntity.data.coins
            
        case .failure(let error):
            print("DEBUG: failed to fetch coins – \(error.description)")
            state = .error(error.description)
            return []
        }
    }
    
    func fetchCoinDetail(uuid: String, timePeriod: String) async -> CoinDetail? {
        state = .isLoading
        
        let result = await coinsUseCases.executeGetCoinDetail(uuid: uuid, timePeriod: timePeriod)
        
        switch result {
        case .success(let responseEntity):
            coinDetailResponse = responseEntity
            state = .good
            return responseEntity.data?.coin
            
        case .failure(let error):
            print("DEBUG: failed to fetch coin detail – \(error.description)")
            state = .error(error.description)
            return nil
        }
    }
    
    func fetchTags() async -> TagDetailsResponse? {
        state = .isLoading
        
        let result = await coinsUseCases.executeGetTags()
        
        switch result {
        case .success(let responseEntity):
            tagDetails = responseEntity
            state = .good
            return responseEntity
            
        case .failure(let error):
            print("DEBUG: failed to fetch coin detail – \(error.description)")
            state = .error(error.description)
            return nil
        }
    }
    
    func fetchTrendingCoins() async -> TrendingCoinResponse? {
        state = .isLoading
        
        let result = await coinsUseCases.executeGetTrendingCoins()
        
        switch result {
        case .success(let responseEntity):
            trendingCoinsResponse = responseEntity
            state = .good
            return responseEntity
            
        case .failure(let error):
            print("DEBUG: failed to fetch trending coins – \(error.description)")
            state = .error(error.description)
            return nil
        }
    }
}

