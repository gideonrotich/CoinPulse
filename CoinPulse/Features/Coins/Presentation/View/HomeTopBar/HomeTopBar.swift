//
//  HomeTopBar.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 15/07/2025.
//

import SwiftUI

struct HomeTopBar: View {
    var onSearch: () -> Void = { }
    var onNotifications: () -> Void = { }
    var onCandy: () -> Void = { }
    
    var body: some View {
        HStack(spacing: 12) {
            
            HStack(spacing: 8) {
                Image("applogo")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
                Text("CoinPulse")
                    .font(.headline.weight(.bold))
            }
            
            Spacer()
            
            Button(action: onCandy) {
                ZStack(alignment: .topTrailing) {
                    Image("candle")
                        .resizable()
                        .frame(width: 28, height: 32)
                }
            }
            
            Button(action: onNotifications) {
                Image(systemName: "bell")
                    .font(.system(size: 20, weight: .semibold))
            }
            
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 20, weight: .semibold))
            }
        }
        .foregroundColor(.primary)
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
    }
}

