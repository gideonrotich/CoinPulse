//
//  CoreDataTests.swift
//  CoinPulseTests
//

import XCTest
import CoreData
@testable import CoinPulse

private func makeCoin(uuid: String = UUID().uuidString) -> Coin {
    .init(uuid: uuid,
          symbol: "TST",
          name: "Test Coin",
          iconURL: "", marketCap: "1000", price: "123", change: "1.2")
}

final class CoreDataTests: XCTestCase {

    private lazy var container: NSPersistentContainer = {
        let c = NSPersistentContainer(name: "CoreData")
        let d = NSPersistentStoreDescription()
        d.type = NSInMemoryStoreType
        c.persistentStoreDescriptions = [d]

        let exp = expectation(description: "loadPersistentStores")
        c.loadPersistentStores { _, error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        wait(for: [exp], timeout: 2)
        return c
    }()
    private var ctx: NSManagedObjectContext { container.viewContext }

    private var sut: LocalFavouritesDataSource!

    
    override func setUp() {
        super.setUp()
        sut = LocalFavouritesDataSource(context: ctx)
    }
    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSaveAndFetch() {
        let coin = makeCoin()
        sut.saveCoin(coin: coin)

        let fetched = sut.fetchFavourites()
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.uuid, coin.uuid)
    }

    func testDuplicateSaveDoesNotCreateDuplicates() {
        let coin = makeCoin(uuid: "dup‑uuid")
        sut.saveCoin(coin: coin)
        sut.saveCoin(coin: coin)

        let fetched = sut.fetchFavourites()
       
        XCTAssertEqual(fetched.filter { $0.uuid == "dup‑uuid" }.count, 1,
                       "Duplicate uuid should not be persisted twice")
    }

    func testDeleteRemovesCoin() {
        let coin = makeCoin()
        sut.saveCoin(coin: coin)
        sut.deleteCoin(coin: coin)

        let fetched = sut.fetchFavourites()
        XCTAssertFalse(fetched.contains { $0.uuid == coin.uuid })
    }

    func testDeleteNonExistingDoesNotCrash() {
        let coin = makeCoin()
        
        XCTAssertNoThrow(sut.deleteCoin(coin: coin))
    }

    func testMappingCoinLocalToCoinIntegrity() {
        let coin = makeCoin(uuid: "mapTest")
        sut.saveCoin(coin: coin)

        guard let first = sut.fetchFavourites().first else {
            XCTFail("Expected a coin back")
            return
        }
        XCTAssertEqual(first.name,    coin.name)
        XCTAssertEqual(first.symbol,  coin.symbol)
        XCTAssertEqual(first.price,   coin.price)
        XCTAssertEqual(first.marketCap, coin.marketCap)
    }
}
