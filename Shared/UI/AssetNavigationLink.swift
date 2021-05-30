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
    let decodeBundle: Bundle
    
    var pointsOfInterest: [Entries.Asset.LocalizedPointOfInterest] {
        asset.decodePointsOfInterest(from: decodeBundle)
            .sorted { $0.timeInterval < $1.timeInterval }
    }
    
    var navigationTitle: String {
        pointsOfInterest.first?.value ?? asset.accessibilityLabel
    }
    
    var body: some View {
        NavigationLink(
            pointsOfInterest.first?.value ?? "No points of interest",
            destination: AssetView(asset: asset, pointsOfInterest: pointsOfInterest)
        )
        .font(.body)
    }
}
