//
//  FavoriteViewWrapper.swift
//  CoinPulse
//
//  Created by Gideon Rotich on 14/07/2025.
//

import Foundation
import SwiftUI

struct FavouritesViewWrapper: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> UINavigationController {
        let favouritesVC  = FavouritesViewController()
        let navController = UINavigationController(rootViewController: favouritesVC)

        navController.setNavigationBarHidden(true, animated: false)
        return navController
    }

    func updateUIViewController(_ uiViewController: UINavigationController,
                                context: Context) {

    }
}
