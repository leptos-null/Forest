//
//  AssetNavigationLink.swift
//  Forest
//
//  Created by Leptos on 5/29/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct AssetNavigationLink: View {
    let asset: Entries.Asset
    let pointsOfInterest: [Entries.Asset.LocalizedPointOfInterest]
    
    init(asset: Entries.Asset, decodeBundle: Bundle) {
        self.asset = asset
        self.pointsOfInterest = asset.decodePointsOfInterest(from: decodeBundle)
            .sorted { $0.timeInterval < $1.timeInterval }
    }
    
    var navigationTitle: String {
        pointsOfInterest.first?.value ?? asset.accessibilityLabel
    }
    
    var body: some View {
        NavigationLink(
            navigationTitle,
            destination: AssetView(asset: asset, pointsOfInterest: pointsOfInterest)
        )
        .font(.body)
        .lineLimit(nil)
    }
}
