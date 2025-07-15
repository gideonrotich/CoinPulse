//
//  FetchState.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

enum FetchState: Comparable{
    case good
    case isLoading
    case noResults
    case error(String)
}
