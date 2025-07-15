//
//  ContentView.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 12/07/2025.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            
            HomeViewControllerWrapper()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            FavouritesViewWrapper()
                .tabItem {
                    Label("Favourites", systemImage: "star")
                }
                .tag(1)
        }
        .accentColor(.blue)
    }
}

#Preview {
    RootView()
}


