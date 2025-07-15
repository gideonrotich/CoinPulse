//
//  APICallError.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation

enum APICallError: Error, CustomStringConvertible{
    case badURL
    case urlSession(Error)
    case decoding(DecodingError)
    case custom(String)
    
    var description: String {
        switch self {
        case .badURL:
            return "Bad URL"
        case .urlSession(let error):
            return "URL session error: \(error.localizedDescription)"
        case .decoding(let decodingError):
            return "Decoding error \(decodingError.localizedDescription)"
        case .custom(let error):
            return error
        }
    }
}
