//
//  CoinPulseApp.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import SwiftUI

@main
struct CoinPulseApp: App {
    @StateObject var homeVM       = HomeViewModel()
    @StateObject var favouritesVM = FavouritesViewmodel()
    @State private var showSplash = true
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                SplashView()
            }
            .environmentObject(homeVM)
            .environmentObject(favouritesVM)
        }
    }
}
