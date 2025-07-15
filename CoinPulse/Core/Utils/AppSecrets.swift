//
//  AppSecrets.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import Foundation

enum AppSecrets {
    private static let info = Bundle.main.infoDictionary
    
    static var apiKey: String {
        guard let key = info?["API_KEY"] as? String, !key.isEmpty else {
            fatalError("No key in the info")
        }
        return key
    }
}
