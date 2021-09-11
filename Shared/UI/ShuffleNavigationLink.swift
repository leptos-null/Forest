//
//  ShuffleNavigationLink.swift
//  Forest
//
//  Created by Leptos on 9/10/21.
//  Copyright © 2021 Leptos. All rights reserved.
//

import SwiftUI

struct ShuffleNavigationLink<Label: View>: View {
    let assets: [Entries.Asset]
    let decodeBundle: Bundle
    
    @State var asset: Entries.Asset?
    @State var shouldAutoPlay: Bool
    @State var videoVariant: Entries.Asset.VideoVariant
    
    @ViewBuilder var label: () -> Label
    
    init(assets: [Entries.Asset], decodeBundle: Bundle,
         shouldAutoPlay: State<Bool> = State(initialValue: false),
         videoVariant: State<Entries.Asset.VideoVariant> = State(initialValue: .c_1080_HDR),
         @ViewBuilder label: @escaping () -> Label) {
        self.assets = assets
        self.decodeBundle = decodeBundle
        self._asset = State(initialValue: assets.randomElement())
        self._shouldAutoPlay = shouldAutoPlay
        self._videoVariant = videoVariant
        self.label = label
    }
    
    private func pointsOfInterest(for asset: Entries.Asset) -> [Entries.Asset.LocalizedPointOfInterest] {
        asset.decodePointsOfInterest(from: decodeBundle)
            .sorted { $0.timeInterval < $1.timeInterval }
    }
    
    var body: some View {
        if let asset = asset {
            NavigationLink(
                destination: AssetView(asset: asset, pointsOfInterest: pointsOfInterest(for: asset), shouldAutoPlay: shouldAutoPlay, videoVariant: _videoVariant) {
                    self.asset = assets.randomElement()
                    shouldAutoPlay = true
                },
                label: label
            )
        }
    }
}
