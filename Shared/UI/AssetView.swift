//
//  AssetView.swift
//  Forest
//
//  Created by Leptos on 5/15/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct AssetView: View {
    let asset: Entries.Asset
    let decodeBundle: Bundle
    
    var pointsOfInterest: [Entries.Asset.LocalizedPointOfInterest] {
        asset.decodePointsOfInterest(from: decodeBundle)
            .sorted { $0.timeInterval < $1.timeInterval }
    }
    
    func stringFrom(seconds: TimeInterval) -> String {
        let secondsPerMinute: TimeInterval = 60
        let divided = seconds/secondsPerMinute
        let minutes = divided.rounded(.towardZero)
        let remainder = seconds - minutes * secondsPerMinute
        return String(format: "%.0f:%02.0f", minutes, remainder)
    }
    
    var body: some View {
        GroupBox {
            DisclosureGroup(pointsOfInterest.first?.value ?? "No points of interest") {
                VStack {
                    if pointsOfInterest.count > 1 {
                        DisclosureGroup("Points of Interest") {
                            VStack {
                                ForEach(pointsOfInterest[1...]) { pointOfInterest in
                                    HStack {
                                        Text("\(pointOfInterest.value) (\(stringFrom(seconds: pointOfInterest.timeInterval)))")
                                        Spacer()
                                    }
                                }
                            }
                            .font(.body)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                        }
                    }
                    DisclosureGroup("URLs") {
                        LazyVStack {
                            ForEach(asset.links) { link in
                                AssetPlayerView(link: link, pointsOfInterest: pointsOfInterest)
                            }
                        }
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                }
                .font(.title3)
                .padding(.horizontal, 16)
            }
            .font(.title2)
            .padding(.horizontal, 16)
        }
    }
}
