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
    let pointsOfInterest: [Entries.Asset.LocalizedPointOfInterest]
    
    func stringFrom(seconds: TimeInterval) -> String {
        let secondsPerMinute: TimeInterval = 60
        let divided = seconds/secondsPerMinute
        let minutes = divided.rounded(.towardZero)
        let remainder = seconds - minutes * secondsPerMinute
        return String(format: "%.0f:%02.0f", minutes, remainder)
    }
    
    var body: some View {
        List {
            Section(header: Text("Points of Interest").foregroundColor(.gray)) {
                ForEach(pointsOfInterest) { pointOfInterest in
                    HStack {
                        Text(pointOfInterest.value)
                        Spacer()
                        Text(stringFrom(seconds: pointOfInterest.timeInterval))
                            .font(.footnote)
                    }
                }
                .font(.body)
                .padding(.horizontal, 16)
            }
            .font(.headline)
            Section(header: Text("URLs").foregroundColor(.gray)) {
                ForEach(asset.links) { link in
                    AssetPlayerView(link: link, pointsOfInterest: pointsOfInterest)
                }
                .font(.body)
                .padding(.horizontal, 16)
            }
            .font(.headline)
        }
        .navigationTitle(asset.accessibilityLabel)
        .listStyle(SidebarListStyle())
    }
}
