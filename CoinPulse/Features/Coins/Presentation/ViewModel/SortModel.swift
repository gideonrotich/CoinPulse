//
//  SortModel.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import Foundation
import Combine

enum SortKey { case marketCap, price, change24h }

struct SortDescriptor {
    var key: SortKey  = .marketCap
    var ascending: Bool = false
}

final class SortingModel: ObservableObject {
    @Published var descriptor = SortDescriptor()
    
    func pick(_ key: SortKey) {
        if descriptor.key == key {
            descriptor = .init(key: key, ascending: !descriptor.ascending)
        } else {
            descriptor = .init(key: key, ascending: false)
        }
    }
}
