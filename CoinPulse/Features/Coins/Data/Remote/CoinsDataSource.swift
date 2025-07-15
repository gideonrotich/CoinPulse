//
//  CoinsDataSource.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

struct CoinsDataSource {
    func getCoins(limit: String, offset: String) async -> Result<CoinsModel, APICallError> {
        var components = URLComponents(string: "\(Constants.baseURL)/coins/")
        
        components?.queryItems = [
            URLQueryItem(name: "limit", value: limit),
            URLQueryItem(name: "offset", value: offset)
        ]
        
        guard let url = components?.url else {
            return .failure(.badURL)
        }
        
        let result = await APICallUtil.shared.fetch(returnType: CoinsModel.self, url: url)
        return result
    }
    
    func getCoinDetails(
        uuid: String,
        timePeriod: String = "24h"
    ) async -> Result<CoinDetailsResponse, APICallError> {
        
        var components = URLComponents(string: "\(Constants.baseURL)/coin/\(uuid)")
        components?.queryItems = [
            URLQueryItem(name: "timePeriod", value: timePeriod)
        ]
        
        guard let url = components?.url else { return .failure(.badURL) }
        return await APICallUtil.shared.fetch(returnType: CoinDetailsResponse.self, url: url)
    }
    
    func getTags() async -> Result<TagDetailsResponse, APICallError> {
        
        let components = URLComponents(string: "\(Constants.baseURL)/tags")
        
        guard let url = components?.url else { return .failure(.badURL) }
        return await APICallUtil.shared.fetch(returnType: TagDetailsResponse.self, url: url)
    }
    
    func getTrendingCoins() async -> Result<TrendingCoinResponse, APICallError> {
        
        let components = URLComponents(string: "\(Constants.baseURL)/coins/trending")
        
        guard let url = components?.url else { return .failure(.badURL) }
        return await APICallUtil.shared.fetch(returnType: TrendingCoinResponse.self, url: url)
    }
}

