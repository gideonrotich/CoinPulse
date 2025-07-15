//
//  LocalFavouritesDataSource.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import Foundation
import CoreData

class LocalFavouritesDataSource {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext = DataProvider.shared.nsPersistentContainer.viewContext) {
        self.viewContext = context
    }
    
    func fetchFavourites() -> [Coin] {
        let request = CoinLocal.fetchRequest()
        do {
            let coinLocals: [CoinLocal] = try viewContext.fetch(request)
            let coins = coinLocals.compactMap { coinLocal -> Coin? in
                return Coin(coinLocal: coinLocal)
            }
            print("fetchFavourites coins: \(coins)")
            return coins
        }
        catch {
            return []
        }
    }
    
    func saveCoin(coin: Coin) {
        
        let request: NSFetchRequest<CoinLocal> = CoinLocal.fetchRequest()
        request.predicate = NSPredicate(format: "uuid == %@", coin.uuid ?? "")
        request.fetchLimit = 1
        
        let coinLocal: CoinLocal
        if let existing = try? viewContext.fetch(request).first {
            coinLocal = existing
        } else {
            coinLocal = CoinLocal(context: viewContext)
        }
        
        coinLocal.uuid       = coin.uuid
        coinLocal.symbol     = coin.symbol
        coinLocal.name       = coin.name
        coinLocal.iconURL    = coin.iconURL
        coinLocal.price      = coin.price
        coinLocal.marketCap  = coin.marketCap
        coinLocal.change     = coin.change
        
        try? viewContext.save()
    }
    
    func deleteCoin(coin: Coin){
        let request = CoinLocal.fetchRequest()
        do {
            let coinLocals: [CoinLocal] = try viewContext.fetch(request)
            guard let coinLocal = coinLocals.first(where: { $0.uuid == coin.uuid }) else {
                return
            }
            viewContext.delete(coinLocal)
            try? viewContext.save()
        }
        catch {
            
        }
    }
}
