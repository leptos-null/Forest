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
    let shouldAutoPlay: Bool
    
    @State private var pointOfInterestIndex: Int? = 0
    @State private var videoVariant: Entries.Asset.VideoVariant
    
    let playerItemEndCallback: (() -> Void)?
    
    init(asset: Entries.Asset, pointsOfInterest: [Entries.Asset.LocalizedPointOfInterest],
         shouldAutoPlay: Bool = false,
         videoVariant: State<Entries.Asset.VideoVariant> = State(initialValue: .c_1080_HDR),
         playerItemEndCallback: (() -> Void)? = nil) {
        self.asset = asset
        self.pointsOfInterest = pointsOfInterest
        self.shouldAutoPlay = shouldAutoPlay
        self._videoVariant = videoVariant
        self.playerItemEndCallback = playerItemEndCallback
    }
    
    private var playerMetadata:  PlayerView.Metadata {
        let subtitle = pointOfInterestIndex.map { pointsOfInterest[$0].value }
        return PlayerView.Metadata(title: asset.accessibilityLabel, subtitle: subtitle, description: nil)
    }
    
    var body: some View {
        ScrollView {
            PlayerView(
                url: asset.url(for: videoVariant),
                timeStamps: pointsOfInterest.map(\.timeInterval),
                timeStampIndex: $pointOfInterestIndex,
                metadata: playerMetadata,
                shouldAutoPlay: shouldAutoPlay,
                playerItemEndCallback: playerItemEndCallback
            )
            .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
            
            HStack(spacing: 16) {
                Picker("Video Variant", selection: $videoVariant) {
                    ForEach(Entries.Asset.VideoVariant.allCases) { variant in
                        Text(variant.name)
                    }
                }
                .labelsHidden() // on macOS, hides the picker title
                .pickerStyle(.segmented)
                
                Link(destination: asset.url(for: videoVariant)) {
                    Text(Image(systemName: "safari"))
                }
            }
            .padding(.horizontal, 16)
            
            PointsOfInterestTable(pointsOfInterest, activeIndex: pointOfInterestIndex)
                .padding(.top, 8)
                .animation(.easeInOut(duration: 0.45), value: pointOfInterestIndex)
        }
        .navigationTitle(asset.accessibilityLabel)
    }
}
