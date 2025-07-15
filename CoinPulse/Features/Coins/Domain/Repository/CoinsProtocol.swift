//
//  CoinsProtocol.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

protocol CoinsProtocol{
    func getCoins(limit: String, offset: String) async -> Result<CoinsModel, APICallError>
    func getCoinDetails(uuid: String,timePeriod: String) async -> Result<CoinDetailsResponse, APICallError>
    func getTags() async -> Result<TagDetailsResponse, APICallError>
    func getTrendingCoins() async -> Result<TrendingCoinResponse, APICallError>
}
