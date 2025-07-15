//
//  UtilFunctions.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import Foundation

extension Double {
    func abbreviated(maxDigits: Int = 2) -> String {
        let absVal = abs(self)
        let sign   = self < 0 ? "-" : ""
        switch absVal {
        case 1_000_000_000...:
            return "\(sign)\((absVal/1_000_000_000).formatted(.number.precision(.fractionLength(0...maxDigits))))B"
        case 1_000_000...:
            return "\(sign)\((absVal/1_000_000).formatted(.number.precision(.fractionLength(0...maxDigits))))M"
        case 1_000...:
            return "\(sign)\((absVal/1_000).formatted(.number.precision(.fractionLength(0...maxDigits))))K"
        default:
            return "\(self.formatted(.number.precision(.fractionLength(0...maxDigits))))"
        }
    }
}

extension String {
    var double: Double? {
        Double(self)
    }
}

extension Optional where Wrapped == String {
    var double: Double? { self.flatMap { Double($0) } }
}
